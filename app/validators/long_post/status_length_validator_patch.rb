# frozen_string_literal: true

module LongPost
  module StatusLengthValidatorPatch
    DEFAULT_MAX_CHARS = 500

    def self.prepended(base)
      base.class_eval do
        def validate(status)
          return unless status.local? && !status.reblog?
          max_chars = get_max_chars
          Rails.logger.info("MAX_CHARACTER: #{max_chars}")
          status.errors.add(:text, I18n.t('statuses.over_character_limit', max: max_chars)) if too_long?(status)
        end

        private

        def too_long?(status)
          max_chars = get_max_chars
          countable_length(combined_text(status)) > max_chars
        end

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
  end
end
