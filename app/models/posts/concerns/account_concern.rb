# frozen_string_literal: true

module Posts::Concerns::AccountConcern
  extend ActiveSupport::Concern
  
  included do
    has_many :patchwork_drafted_statuses, inverse_of: :account, dependent: :destroy, class_name: "Posts::DraftedStatus"
  end
end
