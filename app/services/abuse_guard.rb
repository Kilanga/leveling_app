# Anti-abus par plausibilité de VOLUME (peu de faux positifs) : bloque le
# spam de validations. S'appuie sur les product_events de complétion.
# Fail-open : en cas d'erreur ou de table absente, ne bloque jamais.
class AbuseGuard
  BURST_WINDOW_SECONDS = 60
  MAX_COMPLETIONS_PER_BURST = 10   # un humain ne valide jamais 10 quêtes en 1 min
  MAX_COMPLETIONS_PER_DAY = 60     # plafond quotidien largement au-dessus d'un usage réel
  COMPLETION_EVENTS = %w[quest_completed system_quest_completed weekly_quest_completed].freeze

  class << self
    # Retourne nil si OK, sinon :burst ou :daily_cap.
    def block_reason(user)
      scope = ProductEvent.where(user_id: user.id, event_name: COMPLETION_EVENTS)
      return :burst if scope.where("created_at >= ?", BURST_WINDOW_SECONDS.seconds.ago).count >= MAX_COMPLETIONS_PER_BURST
      return :daily_cap if scope.where("created_at >= ?", Time.zone.today.beginning_of_day).count >= MAX_COMPLETIONS_PER_DAY

      nil
    rescue StandardError => e
      Rails.logger.warn("[AbuseGuard] #{e.class}: #{e.message}")
      nil
    end
  end
end
