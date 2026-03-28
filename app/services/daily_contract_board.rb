class DailyContractBoard
  CONTRACT_POOL = [
    { title: "Recuperation express", description: "Valide 2 quetes avant la fin de la journee.", target_count: 2, reward_coins: 45, risk_tier: "safe" },
    { title: "Operation sous pression", description: "Valide 3 quetes pour un bonus solide.", target_count: 3, reward_coins: 80, risk_tier: "medium" },
    { title: "Mission noire", description: "Valide 4 quetes pour la meilleure prime du jour.", target_count: 4, reward_coins: 130, risk_tier: "high" },
    { title: "Couloir critique", description: "Enchaine 3 validations et securise la prime.", target_count: 3, reward_coins: 90, risk_tier: "medium" },
    { title: "Frappe opportune", description: "Place 2 validations avant le reset quotidien.", target_count: 2, reward_coins: 50, risk_tier: "safe" }
  ].freeze

  def self.ensure_for_today!
    today = Time.zone.today
    DailyContract.transaction do
      DailyContract.connection.execute("LOCK TABLE daily_contracts IN EXCLUSIVE MODE")

      existing = DailyContract.where(active_on: today)
      return existing if existing.count >= 3

      used_titles = existing.pluck(:title)
      candidates = CONTRACT_POOL.reject { |entry| used_titles.include?(entry[:title]) }
      candidates = CONTRACT_POOL if candidates.size < 3 - existing.count

      candidates.sample(3 - existing.count).each do |entry|
        DailyContract.find_or_create_by!(active_on: today, title: entry[:title]) do |contract|
          contract.description = entry[:description]
          contract.target_count = entry[:target_count]
          contract.reward_coins = entry[:reward_coins]
          contract.risk_tier = entry[:risk_tier]
        end
      end

      DailyContract.where(active_on: today)
    end
  end
end
