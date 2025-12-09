# frozen_string_literal: true

module Posts::Concerns::DraftStatusService
  extend ActiveSupport::Concern

  # Post a text status update, fetch and notify remote users mentioned
  # @param [Account] account Account from which to post
  # @param [Hash] options
  # @option [String] :text Message
  # @option [Status] :thread Optional status to reply to
  # @option [Boolean] :sensitive
  # @option [String] :visibility
  # @option [String] :spoiler_text
  # @option [String] :language
  # @option [String] :scheduled_at
  # @option [Hash] :poll Optional poll to attach
  # @option [Enumerable] :media_ids Optional array of media IDs to attach
  # @option [Doorkeeper::Application] :application
  # @option [String] :idempotency Optional idempotency key
  # @option [Boolean] :with_rate_limit
  # @option [Enumerable] :allowed_mentions Optional array of expected mentioned account IDs, raises `UnexpectedMentionsError` if unexpected accounts end up in mentions
  # @return [Status]
  def call(account, options = {})

    @account     = account
    @options     = options
    @text        = @options[:text] || ''
    @in_reply_to = @options[:thread]

    @antispam = Antispam.new

    return idempotency_duplicate if idempotency_given? && idempotency_duplicate?

    validate_media!
    preprocess_attributes!

    if scheduled?
      schedule_status!
    elsif drafted?
      draft_status!
    else
      process_status!
    end

    redis.setex(idempotency_key, 3_600, @status.id) if idempotency_given?

    unless scheduled? || drafted?
      postprocess_status!
      bump_potential_friendship!
    end

    @status
  rescue Antispam::SilentlyDrop => e
    e.status
  end

  private

  def preprocess_attributes!
    @sensitive    = (@options[:sensitive].nil? ? @account.user&.setting_default_sensitive : @options[:sensitive]) || @options[:spoiler_text].present?
    @text         = @options.delete(:spoiler_text) if @text.blank? && @options[:spoiler_text].present?
    @visibility   = @options[:visibility] || @account.user&.setting_default_privacy
    @visibility   = :unlisted if @visibility&.to_sym == :public && @account.silenced?
    @scheduled_at = @options[:scheduled_at]&.to_datetime
    @scheduled_at = nil if scheduled_in_the_past?
    @drafted      = @options[:drafted]
  rescue ArgumentError
    raise ActiveRecord::RecordInvalid
  end

  def drafted?
    @drafted.present?
  end

  def draft_status!
    status_for_validation = @account.statuses.build(status_attributes)
    @antispam.local_preflight_check!(status_for_validation)

    if status_for_validation.valid?
      # Marking the status as destroyed is necessary to prevent the status from being
      # persisted when the associated media attachments get updated when creating the
      # scheduled status.
      status_for_validation.destroy

      # The following transaction block is needed to wrap the UPDATEs to
      # the media attachments when the drafted status is created

      ApplicationRecord.transaction do
        @status = @account.patchwork_drafted_statuses.create!(drafted_status_attributes)
      end
    else
      raise ActiveRecord::RecordInvalid
    end
  rescue Antispam::SilentlyDrop
    @status = @account.patchwork_drafted_status.new(drafted_status_attributes).tap(&:delete)
  end

  def drafted_status_attributes
    {
      media_attachments: @media || [],
      params: scheduled_options,
    }
  end

  def postprocess_status!
    process_hashtags_service.call(@status)
    Trends.tags.register(@status)
    LinkCrawlWorker.perform_async(@status.id)
    DistributionWorker.perform_async(@status.id)

    ActivityPub::DistributionWorker.perform_async(@status.id) unless @status.local_only?
    PollExpirationNotifyWorker.perform_at(@status.poll.expires_at, @status.poll.id) if @status.poll
  end

  def local_only_option(local_only, in_reply_to)
    if local_only.nil?
      return true if in_reply_to&.local_only
      return false if in_reply_to && !in_reply_to.local_only
    end
    local_only
  end

  def status_attributes
    {
      text: @text,
      media_attachments: @media || [],
      ordered_media_attachment_ids: (@options[:media_ids] || []).map(&:to_i) & @media.map(&:id),
      thread: @in_reply_to,
      poll_attributes: poll_attributes,
      sensitive: @sensitive,
      spoiler_text: @options[:spoiler_text] || '',
      visibility: @visibility,
      language: valid_locale_cascade(@options[:language], @account.user&.preferred_posting_language, I18n.default_locale),
      application: @options[:application],
      rate_limit: @options[:with_rate_limit],
      local_only: local_only_option(@options[:local_only], @in_reply_to),
    }.compact
  end
end
