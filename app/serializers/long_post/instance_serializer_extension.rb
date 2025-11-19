# frozen_string_literal: true

module LongPost
  module InstanceSerializerExtension
    DEFAULT_MAX_CHARS = 500

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
        # Early return if Posts::ServerSetting doesn't exist
        return DEFAULT_MAX_CHARS unless Object.const_defined?('Posts::ServerSetting')
        
        begin
          long_post = Posts::ServerSetting.get_long_post('Long posts')
          
          # Handle nil long_post
          return DEFAULT_MAX_CHARS if long_post.nil?
          
          # Handle when value is false or nil
          return DEFAULT_MAX_CHARS unless long_post.value
          
          # Handle optional_value being nil or non-numeric
          optional_value = long_post.optional_value
          return DEFAULT_MAX_CHARS if optional_value.nil? || optional_value.to_s.strip.empty?
          
          # Convert to integer and validate it's positive
          max_chars = optional_value.to_i
          return DEFAULT_MAX_CHARS if max_chars <= 0
          
          max_chars
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.warn("Long posts setting not found: #{e.message}")
          DEFAULT_MAX_CHARS
        rescue ActiveRecord::StatementInvalid => e
          Rails.logger.error("Database error in get_max_chars: #{e.message}")
          DEFAULT_MAX_CHARS
        rescue NoMethodError => e
          Rails.logger.error("Method error in get_max_chars (possible nil reference): #{e.message}")
          DEFAULT_MAX_CHARS
        rescue StandardError => e
          Rails.logger.error("Unexpected error in get_max_chars: #{e.class} - #{e.message}")
          DEFAULT_MAX_CHARS
        end
      end
  end
end
