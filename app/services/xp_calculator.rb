module XpCalculator
  module_function

  def xp_needed_for_next_level(level)
    l = [ level.to_i, 1 ].max
    previous_levels = l - 1

    # Monotonic blended curve: fast onboarding, then steady ramp-up without drop-offs.
    (120 + (55 * previous_levels) + (12 * (previous_levels**1.45))).round
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

    [ level, xp_remaining ]
  end
end
