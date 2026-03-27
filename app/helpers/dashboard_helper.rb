module DashboardHelper
  def xp_needed_until_level(level)
    (1...level).sum { |lvl| xp_needed_for_next_level(lvl) }
  end

  def xp_needed_for_next_level(level)
    XpCalculator.xp_needed_for_next_level(level)
  end
end
