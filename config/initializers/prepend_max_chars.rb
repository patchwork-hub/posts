# frozen_string_literal: true

Rails.application.config.to_prepare do
  StatusLengthValidator.prepend(LongPost::StatusLengthValidatorPatch)
  REST::V1::InstanceSerializer.prepend(LongPost::InstanceSerializerExtension)
  REST::InstanceSerializer.prepend(LongPost::InstanceSerializerExtension)
  REST::StatusSerializer.include(Posts::StatusSerializerExtension)
  MediaAttachment.include(Posts::Concerns::MediaAttachmentConcern)
  Account.include(Posts::Concerns::AccountConcern)
  PostStatusService.prepend(Posts::Concerns::DraftStatusService)
  ReblogService.prepend(Posts::ReblogServiceExtension)
  Status.include(Posts::Concerns::StatusConcern)
  AccountStatusesFilter.prepend(Overrides::ExtendedAccountStatusesFilter)
  Api::V1::ScheduledStatusesController.prepend(Overrides::ScheduledStatusesController)
  Api::V2::NotificationsController.prepend(Overrides::NotificationExtendedController)
  Api::V1::NotificationsController.prepend(Overrides::NotificationV1ExtendedController)
  Notification.prepend(Posts::Concerns::NotificationConcern)
  Api::V1::StatusesController.prepend(Posts::Api::V1::StatusesControllerExtension)
end
