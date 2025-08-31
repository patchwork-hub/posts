# frozen_string_literal: true

module Posts::Concerns::MediaAttachmentConcern
  extend ActiveSupport::Concern  

  included do
    belongs_to :patchwork_drafted_status, inverse_of: :media_attachments, optional: true , class_name: "Posts::DraftedStatus"

    scope :attached,   -> { where.not(status_id: nil).or(where.not(scheduled_status_id: nil)).or(where.not(patchwork_drafted_status_id: nil)) }
    scope :unattached, -> { where(status_id: nil, scheduled_status_id: nil, patchwork_drafted_status_id: nil) }
    
    after_save :call_generate_alt_text_worker if ENV['ALT_TEXT_ENABLED'].present? && ENV['ALT_TEXT_ENABLED'].to_s.downcase == 'true'

    def can_generate_alt?
      if image_file? && check_user_desc? && local_or_reblogged_status?
        return true
      else
        return false
      end
    end
    
    def check_user_desc?
      !self.description.present?
    end

    def image_file?
      self.file_content_type.start_with?("image/")
    end

    def local_or_reblogged_status?
      if self.status_id.present?
        status = self.status
        return true if status.local? || status.reply?

        status.reblog? && status.account.domain.nil?
      else
        return false
      end
    end
  end

  private

  def call_generate_alt_text_worker
    return unless self.can_generate_alt?

    GenerateAltTextWorker.perform_async(self.id)
  end
end