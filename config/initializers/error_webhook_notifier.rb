# Monitoring léger sans dépendance : notifie un webhook (Discord/Slack) à
# chaque exception NON gérée du cycle requête. Utilise uniquement la stdlib.
# No-op si ERROR_WEBHOOK_URL n'est pas défini → aucun risque en prod.
#
# Configuration : heroku config:set ERROR_WEBHOOK_URL="https://discord.com/api/webhooks/..."
require "net/http"
require "uri"
require "json"

class ErrorWebhookNotifier
  MAX = 1800

  def report(error, handled:, severity:, context:, source: nil)
    return if handled
    url = ENV["ERROR_WEBHOOK_URL"].to_s
    return if url.empty?

    ctx = context.is_a?(Hash) ? context : {}
    location = ctx[:path] || ctx[:controller] || source
    text = +"🚨 [#{Rails.env}] #{error.class}: #{error.message.to_s[0, 300]}\n"
    text << "#{location}\n" if location
    text << Array(error.backtrace).first(4).join("\n").to_s

    Net::HTTP.post(URI(url), { content: text[0, MAX] }.to_json, "Content-Type" => "application/json")
  rescue StandardError => e
    Rails.logger.warn("[ErrorWebhookNotifier] échec de notification: #{e.class} #{e.message}")
  end
end

Rails.error.subscribe(ErrorWebhookNotifier.new) if ENV["ERROR_WEBHOOK_URL"].present?
