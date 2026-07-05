# Crée une notification in-app traduite dans la langue du destinataire.
# Les clés vivent sous notifications.<kind>.{title,body}.
class InAppNotifier
  class << self
    def notify!(user:, kind:, cta_path: nil, **i18n_params)
      locale = user.locale.presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale

      I18n.with_locale(locale) do
        title = I18n.t("notifications.#{kind}.title", **i18n_params)
        body = I18n.t("notifications.#{kind}.body", **i18n_params)

        notification = InAppNotification.create!(
          user: user, kind: kind, title: title, body: body, cta_path: cta_path
        )
        WebPushSender.call(user: user, title: title, body: body, path: cta_path || "/")
        notification
      end
    end
  end
end
