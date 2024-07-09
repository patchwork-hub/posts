Rails.application.config.to_prepare do
  StatusLengthValidator.prepend LongPost::StatusLengthValidatorPatch
  REST::V1::InstanceSerializer.prepend LongPost::InstanceSerializerExtension
  REST::InstanceSerializer.prepend LongPost::InstanceSerializerExtension
end
