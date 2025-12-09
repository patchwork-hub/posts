module Posts::StatusSerializerExtension
  extend ActiveSupport::Concern

  included do
    attributes :local_only
  end
end
