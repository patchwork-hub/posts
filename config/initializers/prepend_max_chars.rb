Rails.application.config.after_initialize do
  StatusLengthValidator.prepend LongPost::StatusLengthValidatorPatch
  REST::V1::InstanceSerializer.prepend LongPost::InstanceSerializerExtension
  REST::InstanceSerializer.prepend LongPost::InstanceSerializerExtension
end
