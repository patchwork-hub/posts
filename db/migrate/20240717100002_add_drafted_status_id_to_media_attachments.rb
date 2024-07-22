# frozen_string_literal: true

class AddDraftedStatusIdToMediaAttachments < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    safety_assured { add_reference :media_attachments, :patchwork_drafted_status, foreign_key: { on_delete: :nullify }, index: false }
    add_index :media_attachments, :patchwork_drafted_status_id, algorithm: :concurrently
  end
end


