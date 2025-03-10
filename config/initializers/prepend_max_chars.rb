# frozen_string_literal: true

Rails.application.config.to_prepare do
  StatusLengthValidator.prepend(LongPost::StatusLengthValidatorPatch)
  REST::V1::InstanceSerializer.prepend(LongPost::InstanceSerializerExtension)
  REST::InstanceSerializer.prepend(LongPost::InstanceSerializerExtension)
  MediaAttachment.include(Posts::Concerns::MediaAttachmentConcern)
  Account.include(Posts::Concerns::AccountConcern)
  PostStatusService.prepend(Posts::Concerns::DraftStatusService)
end
