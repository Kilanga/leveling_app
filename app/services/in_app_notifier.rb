# Crée une notification in-app traduite dans la langue du destinataire.
# Les clés vivent sous notifications.<kind>.{title,body}.
class InAppNotifier
  class << self
    def notify!(user:, kind:, cta_path: nil, **i18n_params)
      locale = user.locale.presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale

      I18n.with_locale(locale) do
        InAppNotification.create!(
          user: user,
          kind: kind,
          title: I18n.t("notifications.#{kind}.title", **i18n_params),
          body: I18n.t("notifications.#{kind}.body", **i18n_params),
          cta_path: cta_path
        )
      end
    end
  end
end
