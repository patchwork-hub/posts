# frozen_string_literal: true

require 'posts/application_record'

module Posts
  class PatchworkSetting < ApplicationRecord
    self.table_name = 'patchwork_settings'
  end
end
