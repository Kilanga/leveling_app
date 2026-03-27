class ProductAnalytics
  class << self
    def track(user:, event_name:, metadata: {})
      ProductEvent.create!(
        user: user,
        event_name: event_name,
        metadata_json: metadata.to_json
      )
    rescue StandardError => e
      Rails.logger.warn("ProductAnalytics track failed: #{e.class} #{e.message}")
      nil
    end
  end
end
