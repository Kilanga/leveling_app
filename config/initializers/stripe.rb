Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_PUBLIC_KEY"].presence || Rails.application.credentials.dig(:stripe, :public_key),
  secret_key: ENV["STRIPE_SECRET_KEY"].presence || Rails.application.credentials.dig(:stripe, :secret_key),
  webhook_secret: ENV["STRIPE_WEBHOOK_SECRET"].presence || Rails.application.credentials.dig(:stripe, :webhook_secret),
  webhook_secrets: [
    ENV["STRIPE_WEBHOOK_SECRET"].presence,
    ENV["STRIPE_WEBHOOK_SECRET_FALLBACK"].presence,
    Rails.application.credentials.dig(:stripe, :webhook_secret)
  ].compact.uniq
}

Stripe.api_key = Rails.configuration.stripe[:secret_key] if Rails.configuration.stripe[:secret_key].present?
