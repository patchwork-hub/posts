# frozen_string_literal: true

module LongPost
  module StatusLengthValidatorPatch
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
          long_post = Posts::ServerSetting.get_long_post('Long posts')
          long_post&.value ? long_post&.optional_value.to_i : 500
        end
      end
    end
  end
end
