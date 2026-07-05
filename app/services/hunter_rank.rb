# Rang de chasseur permanent (E -> S), calculé depuis le niveau total.
# C'est l'identité long-terme du joueur ; il ne redescend jamais.
class HunterRank
  THRESHOLDS = [
    [ "E", 0 ],
    [ "D", 10 ],
    [ "C", 25 ],
    [ "B", 50 ],
    [ "A", 85 ],
    [ "S", 130 ]
  ].freeze

  class << self
    def for_level(total_level)
      level = total_level.to_i
      index = THRESHOLDS.rindex { |(_letter, min)| level >= min } || 0
      letter, current_min = THRESHOLDS[index]
      next_rank = THRESHOLDS[index + 1]

      progress =
        if next_rank
          span = next_rank[1] - current_min
          span.positive? ? [ (level - current_min).to_f / span, 1.0 ].min : 1.0
        else
          1.0
        end

      {
        letter: letter,
        next_letter: next_rank&.first,
        level: level,
        current_threshold: current_min,
        next_threshold: next_rank&.last,
        progress: progress.round(3)
      }
    end

    def for_user(user)
      for_level(user.user_stats.sum(:level))
    end
  end
end
