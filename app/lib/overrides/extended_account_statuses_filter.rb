# frozen_string_literal: true
module Overrides::ExtendedAccountStatusesFilter
  include Redisable

  KEYS = %i(
    pinned
    tagged
    only_media
    exclude_replies
    exclude_reblogs
    only_reblogs
    exclude_original_statuses
    exclude_direct_statuses
    include_custom_timelines
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
    scope.merge!(no_direct_statuses_scope) if exclude_direct_statuses?
    scope.merge!(custom_scope) if include_custom_timelines?

    scope
  end

  private

  def only_rebogs_scope
    Status.fetch_reblogs
  end

  def no_original_statuses_scope
    Status.without_original_statuses
  end

  def no_direct_statuses_scope
    Status.without_direct_statuses
  end

  def only_reblogs?
    truthy_param?(:only_reblogs)
  end

  def exclude_original_statuses?
    truthy_param?(:exclude_original_statuses)
  end

  def exclude_direct_statuses?
    truthy_param?(:exclude_direct_statuses)
  end

  def include_custom_timelines?
    truthy_param?(:include_custom_timelines)
  end

  # for custom timelines
  def custom_scope
    status_ids = redis.zrange(FeedManager.instance.key(:custom, @account.id), 0, -1)
    Status.where(id: status_ids).joins(:account).merge(Account.without_suspended.without_silenced)
  end
end
