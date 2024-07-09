module LongPost
  module InstanceSerializerExtension
    def configuration
      super.merge(
        statuses: {
          max_characters: get_max_chars,
          max_media_attachments: 4,
          characters_reserved_per_url: StatusLengthValidator::URL_PLACEHOLDER_CHARS,
        }
      )
    end

    private

    def get_max_chars
      setting = Posts::ServerSetting.get_long_post('Long posts and markdown')
      setting&.value ? setting.optional_value.to_i : 500
    end
  end
end
