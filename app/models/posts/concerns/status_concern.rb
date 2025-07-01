# frozen_string_literal: true

module Posts::Concerns::StatusConcern
  extend ActiveSupport::Concern
  
  included do
    scope :fetch_reblogs, -> { where.not(statuses: { reblog_of_id: nil }) }
  end
end