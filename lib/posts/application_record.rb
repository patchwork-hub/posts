# frozen_string_literal: true

module Posts
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
