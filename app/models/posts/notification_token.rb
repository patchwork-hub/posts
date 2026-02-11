# frozen_string_literal: true

require 'posts/application_record'

module Posts
  class NotificationToken < ApplicationRecord
    self.table_name = 'patchwork_notification_tokens'
  end
end
