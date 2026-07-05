module SeasonPassesHelper
  # Libellé lisible d'une récompense de palier ({ fragments: 40, orbs: 60, ... }).
  def season_pass_reward_label(reward)
    parts = []
    parts << t("season_pass.rewards.fragments", count: reward[:fragments]) if reward[:fragments].to_i.positive?
    parts << t("season_pass.rewards.orbs", count: reward[:orbs]) if reward[:orbs].to_i.positive?
    parts << t("season_pass.rewards.boost", count: reward[:boost_days]) if reward[:boost_days].to_i.positive?
    parts << t("season_pass.rewards.title") if reward[:title]
    parts.join(" + ")
  end
end
