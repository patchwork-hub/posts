# frozen_string_literal: true
module Overrides::ExtendedAccountStatusesFilter
  KEYS = %i(
    pinned
    tagged
    only_media
    exclude_replies
    exclude_reblogs
    only_reblogs
  ).freeze

  def results
    scope = initial_scope

    scope.merge!(pinned_scope)     if pinned?
    scope.merge!(only_media_scope) if only_media?
    scope.merge!(no_replies_scope) if exclude_replies?
    scope.merge!(no_reblogs_scope) if exclude_reblogs?
    scope.merge!(no_original_statuses_scope) if exclude_original_statuses?
    scope.merge!(hashtag_scope) if tagged?
    scope.merge!(only_rebogs_scope) if only_reblogs?

    scope
  end

  private

  def only_rebogs_scope
    Status.fetch_reblogs
  end

  def only_reblogs?
    truthy_param?(:only_reblogs)
  end
end
