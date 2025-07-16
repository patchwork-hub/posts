# frozen_string_literal: true

module Posts::Concerns::MediaAttachmentConcern
  extend ActiveSupport::Concern  


  included do
    belongs_to :patchwork_drafted_status, inverse_of: :media_attachments, optional: true , class_name: "Posts::DraftedStatus"

    scope :attached,   -> { where.not(status_id: nil).or(where.not(scheduled_status_id: nil)).or(where.not(patchwork_drafted_status_id: nil)) }
    scope :unattached, -> { where(status_id: nil, scheduled_status_id: nil, patchwork_drafted_status_id: nil) }
    
    after_save :call_generate_alt_text_worker

    IMAGE_ALLOW_TYPES = %w(image/jpeg image/png image/gif image/webp image/bmp).freeze

    def can_generate_alt?
      if is_valid_content_type? && check_file_size? && generate_alt_text? && check_user_desc? && is_end_user_upload?
        return true
      else
        return false
      end
    end
    
    def check_user_desc?
      flag = !self.description.present?
      Rails.logger.info "description is already exists" if !flag
      return flag
    end

    def generate_alt_text?
      ActiveModel::Type::Boolean.new.cast(ENV['GENERATE_ALT_TEXT'])
    end

    def is_valid_content_type?
      flag = IMAGE_ALLOW_TYPES.include?(self.file_content_type)
      Rails.logger.info "invalid content_type is : #{self.file_content_type}" if !flag
      return flag
    end

    def check_file_size?
      self.file_file_size <= 10.megabytes
    end

    def is_end_user_upload?
      if self.account.domain.nil?
        return self.account.user.role.name === "" || self.account.user.role.name.empty? 
      end
      return false
    end
  end

  private

  def call_generate_alt_text_worker
    @media_attachment = MediaAttachment.find(id)
    return unless @media_attachment.can_generate_alt?
    
    Rails.logger.info "starting GenerateAltTextWorker"
    GenerateAltTextWorker.perform_async(id)
  end
end