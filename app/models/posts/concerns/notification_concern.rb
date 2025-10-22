# frozen_string_literal: true

module Posts::Concerns::NotificationConcern
  extend ActiveSupport::Concern

  LEGACY_TYPE_CLASS_MAP = {
    'Mention' => :mention,
    'Status' => :reblog,
    'Follow' => :follow,
    'FollowRequest' => :follow_request,
    'Favourite' => :favourite,
    'Poll' => :poll,
  }.freeze

  # Please update app/javascript/api_types/notification.ts if you change this
  PROPERTIES = {
    mention: {
      filterable: true,
    }.freeze,
    status: {
      filterable: false,
    }.freeze,
    reblog: {
      filterable: true,
    }.freeze,
    follow: {
      filterable: true,
    }.freeze,
    follow_request: {
      filterable: true,
    }.freeze,
    favourite: {
      filterable: true,
    }.freeze,
    poll: {
      filterable: false,
    }.freeze,
    update: {
      filterable: false,
    }.freeze,
    severed_relationships: {
      filterable: false,
    }.freeze,
    moderation_warning: {
      filterable: false,
    }.freeze,
    annual_report: {
      filterable: false,
    }.freeze,
    'admin.sign_up': {
      filterable: false,
    }.freeze,
    'admin.report': {
      filterable: false,
    }.freeze,
  }.freeze

  TYPES = PROPERTIES.keys.freeze

  TARGET_STATUS_INCLUDES_BY_TYPE = {
    status: :status,
    reblog: [status: :reblog],
    mention: [mention: :status],
    favourite: [favourite: :status],
    poll: [poll: :status],
    update: :status,
    'admin.report': [report: :target_account],
  }.freeze

  def self.prepended(base)
    # Override class methods
    base.singleton_class.class_eval do
      def browserable(types: [], exclude_types: [], from_account_id: nil, include_filtered: false, only_direct_mentions: false)
        requested_types = if types.empty?
                            TYPES
                          else
                            types.map(&:to_sym) & TYPES
                          end

        requested_types -= exclude_types.map(&:to_sym)

        all.tap do |scope|
          scope.merge!(where(filtered: false)) unless include_filtered || from_account_id.present?
          scope.merge!(where(from_account_id: from_account_id)) if from_account_id.present?
          scope.merge!(where(type: requested_types)) unless requested_types.size == TYPES.size
          scope.merge!(direct_mentions_only) if only_direct_mentions && requested_types.include?(:mention)
        end
      end

      # New scope to filter mentions by direct visibility
      def direct_mentions_only
        left_joins(mention: :status)
          .where(
            '(notifications.type != ? OR statuses.visibility = ?)',
            'mention',
            Status.visibilities[:direct]
          )
      end
    end
  end
end
