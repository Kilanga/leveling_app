class Experimentation
  class << self
    def variant_for(user:, experiment_key:, variants: %w[control treatment])
      assignment = ExperimentAssignment.find_or_initialize_by(user: user, experiment_key: experiment_key)
      if assignment.new_record?
        assignment.variant = stable_variant(user.id, experiment_key, variants)
        assignment.save!
      end
      assignment.variant
    end

    private

    def stable_variant(user_id, experiment_key, variants)
      seed = Zlib.crc32("#{experiment_key}:#{user_id}")
      variants[seed % variants.size]
    end
  end
end
