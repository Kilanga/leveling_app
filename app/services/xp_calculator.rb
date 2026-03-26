module XpCalculator
  module_function

  def xp_needed_for_next_level(level)
    case level
    when 1..10
      level * 100
    when 11..20
      (level**1.8 * 100).to_i
    when 21..30
      (level**1.7 * 100).to_i
    when 31..40
      (level**1.6 * 100).to_i
    when 41..50
      (level**1.5 * 100).to_i
    when 51..60
      (level**1.4 * 100).to_i
    when 61..70
      (level**1.3 * 100).to_i
    when 71..80
      (level**1.2 * 100).to_i
    when 81..90
      (level**1.1 * 100).to_i
    else
      (level**1.1 * 100).to_i
    end
  end

  def calculate_level_and_xp(total_xp)
    level = 1
    xp_remaining = total_xp.to_i

    loop do
      xp_needed = xp_needed_for_next_level(level)
      break if xp_remaining < xp_needed

      xp_remaining -= xp_needed
      level += 1
    end

    [level, xp_remaining]
  end
end
