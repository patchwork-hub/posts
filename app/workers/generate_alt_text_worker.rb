class GenerateAltTextWorker
  include Sidekiq::Worker
  	sidekiq_options queue: 'default', retry: 2, dead: false, retry_in: ->(count) { 24.hours }

    def perform(media_attachment_id)
        @media_attachment = MediaAttachment.find(media_attachment_id)
        if @media_attachment.present?
					if @media_attachment.can_generate_alt?
							Posts::AfterUploadImageService.new(@media_attachment.id).call
					end
        end
    end
end