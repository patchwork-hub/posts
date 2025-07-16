class GenerateAltTextWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: false, dead: true

    def perform(media_attachment_id)
        @media_attachment = MediaAttachment.find(media_attachment_id)
        if @media_attachment.present?
            if @media_attachment.can_generate_alt?
                Posts::AfterUploadImageService.new(@media_attachment.id).call
            else
                Rails.logger.info "media attachment is empty for id : #{@media_attachment.id}"
            end
        end
    end
end