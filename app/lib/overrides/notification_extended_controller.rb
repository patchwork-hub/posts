# frozen_string_literal: true

module Overrides::NotificationExtendedController

  def browserable_account_notifications
    current_account.notifications.without_suspended.browserable(
      types: Array(browserable_params[:types]),
      exclude_types: Array(browserable_params[:exclude_types]),
      include_filtered: truthy_param?(:include_filtered),
      only_direct_mentions: truthy_param?(:only_direct_mentions)
    )
  end

  def browserable_params
    params.slice(:include_filtered, :types, :exclude_types, :grouped_types, :only_direct_mentions).permit(:only_direct_mentions, :include_filtered, types: [], exclude_types: [], grouped_types: [])
  end

  def pagination_params(core_params)
    params.slice(:limit, :include_filtered, :types, :exclude_types, :grouped_types, :only_direct_mentions).permit(:limit, :only_direct_mentions, :include_filtered, types: [], exclude_types: [], grouped_types: []).merge(core_params)
  end
end