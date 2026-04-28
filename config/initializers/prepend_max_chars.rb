# frozen_string_literal: true

Rails.application.config.to_prepare do
  StatusLengthValidator.prepend(LongPost::StatusLengthValidatorPatch)
  REST::V1::InstanceSerializer.prepend(LongPost::InstanceSerializerExtension)
  REST::InstanceSerializer.prepend(LongPost::InstanceSerializerExtension)
  MediaAttachment.include(Posts::Concerns::MediaAttachmentConcern)
  Account.include(Posts::Concerns::AccountConcern)
  PostStatusService.prepend(Posts::Concerns::DraftStatusService)
  Status.include(Posts::Concerns::StatusConcern)
  ProcessHashtagsService.prepend(Posts::Concerns::ProcessHashtagsServiceExtension)
  AccountStatusesFilter.prepend(Overrides::ExtendedAccountStatusesFilter)
  Api::V1::ScheduledStatusesController.prepend(Overrides::ScheduledStatusesController)
  Api::V2::NotificationsController.prepend(Overrides::NotificationExtendedController)
  Api::V1::NotificationsController.prepend(Overrides::NotificationV1ExtendedController)
  Notification.prepend(Posts::Concerns::NotificationConcern)
  if ENV['CUSTOMIZED_FILE_UPLOAD_ENABLED'].present? && ENV['CUSTOMIZED_FILE_UPLOAD_ENABLED'].to_s.downcase == 'true'
    MediaAttachment.prepend(Overrides::MediaAttachmentUploadOverride)
  end
end
