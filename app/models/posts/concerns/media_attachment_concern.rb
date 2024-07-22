# frozen_string_literal: true

module Posts::Concerns::MediaAttachmentConcern
  extend ActiveSupport::Concern  


  included do
    belongs_to :patchwork_drafted_status, inverse_of: :media_attachments, optional: true , class_name: "Posts::DraftedStatus"

    scope :attached,   -> { where.not(status_id: nil).or(where.not(scheduled_status_id: nil)).or(where.not(patchwork_drafted_status_id: nil)) }
    scope :unattached, -> { where(status_id: nil, scheduled_status_id: nil, patchwork_drafted_status_id: nil) }
  end

end