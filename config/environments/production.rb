require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.active_storage.service = :cloudinary
  config.assume_ssl = true
  config.force_ssl = true
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  # config.cache_store = :solid_cache_store
  # config.active_job.queue_adapter = :solid_queue
  # config.solid_queue.connects_to = { database: { writing: :queue } }
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  config.stripe_publishable_key = ENV["STRIPE_PUBLIC_KEY"]
  config.stripe_secret_key = ENV["STRIPE_SECRET_KEY"]
  # Désactiver ActionCable si non utilisé
  config.action_cable.mount_path = nil
  config.action_cable.disable_request_forgery_protection = true

  # Configuration d'ActionCable si nécessaire
  # config.action_cable.url = ENV["CABLE_URL"] || "redis://localhost:6379/1"
  # config.action_cable.allowed_request_origins = [ "https://yourapp.herokuapp.com", "http://yourapp.herokuapp.com" ]

  # Configuration de l'email
  config.action_mailer.default_url_options = { host: ENV["APP_HOST"] || "https://leveling-app-f7f0867fb53e.herokuapp.com/" }

  config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "smtp.sendgrid.net",
  port: 587,
  domain: "arnaudlothe.eu",
  authentication: :plain,
  enable_starttls_auto: true,
  user_name: "apikey",
  password: ENV["SENDGRID_API_KEY"]
}
config.action_mailer.default_url_options = { host: "leveling-app-f7f0867fb53e.herokuapp.com", protocol: "https" }
end
