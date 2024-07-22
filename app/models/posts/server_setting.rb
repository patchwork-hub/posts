# frozen_string_literal: true

require 'posts/application_record'

module Posts
  class ServerSetting < ApplicationRecord
    self.table_name = 'server_settings'

    validates :optional_value, presence: true, allow_nil: true

    belongs_to :parent, class_name: "Posts::ServerSetting", optional: true
    has_many :children, class_name: "Posts::ServerSetting", foreign_key: "parent_id"

    def self.get_long_post(name)
      find_by(name: name)
    end
  end
end
