# Envoie une notification push web à tous les abonnements d'un utilisateur.
# Silencieux si les clés VAPID ne sont pas configurées ; purge les
# abonnements expirés (410/404).
class WebPushSender
  class << self
    def call(user:, title:, body:, path: "/")
      return 0 unless configured?

      sent = 0
      user.push_subscriptions.find_each do |subscription|
        begin
          WebPush.payload_send(
            message: { title: title, options: { body: body, icon: "/icon.png", data: { path: path } } }.to_json,
            endpoint: subscription.endpoint,
            p256dh: subscription.p256dh_key,
            auth: subscription.auth_key,
            vapid: {
              subject: "mailto:#{ENV.fetch('VAPID_SUBJECT', 'contact@arnaudlothe.site')}",
              public_key: ENV["VAPID_PUBLIC_KEY"],
              private_key: ENV["VAPID_PRIVATE_KEY"]
            }
          )
          sent += 1
        rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
          subscription.destroy
        rescue StandardError => e
          Rails.logger.warn("WebPush failed for subscription #{subscription.id}: #{e.class} #{e.message}")
        end
      end
      sent
    end

    def configured?
      ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present?
    end
  end
end
