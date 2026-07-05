# Monitoring d'erreurs — actif uniquement si SENTRY_DSN est défini
# (crée un projet gratuit sur sentry.io et ajoute la variable sur Heroku).
if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
    config.send_default_pii = false
    config.environment = Rails.env
    config.enabled_environments = %w[production]
    # Traces de performance légères (10 % des requêtes)
    config.traces_sample_rate = 0.1
  end
end
