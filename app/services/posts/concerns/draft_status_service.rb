# frozen_string_literal: true

module Posts::Concerns::DraftStatusService
  extend ActiveSupport::Concern  

  #class DraftStatusService

    def call(account, options = {})
      @account     = account
      @options     = options
      @text        = @options[:text] || ''
      @in_reply_to = @options[:thread]

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
  
      if status_for_validation.valid?
        # Marking the status as destroyed is necessary to prevent the status from being
        # persisted when the associated media attachments get updated when creating the
        # scheduled status.
        status_for_validation.destroy
  
        # The following transaction block is needed to wrap the UPDATEs to
        # the media attachments when the drafted status is created
  
        ApplicationRecord.transaction do
          @status = @account.drafted_statuses.create!(drafted_status_attributes)
        end
      else
        raise ActiveRecord::RecordInvalid
      end
    end

    def drafted_status_attributes
      {
        media_attachments: @media || [],
        params: scheduled_options,
      }
    end

  #end
end