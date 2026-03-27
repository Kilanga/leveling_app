class ProductEvent < ApplicationRecord
  belongs_to :user, optional: true

  validates :event_name, presence: true

  def metadata
    JSON.parse(metadata_json.presence || "{}")
  rescue JSON::ParserError
    {}
  end
end
