class OnboardingController < ApplicationController
  before_action :authenticate_user!

  def show
    @categories = []
    @selected_ids = current_user.onboarding_category_ids
    @quest_pool = []
    @recommended_quests = Quest.none

    return unless feature_tables_ready?(:categories, :quests)

    @categories = Category.order(:name)
    @quest_pool = Quest.includes(:category)
                      .where(category_id: @categories.select(:id))
                      .order(xp: :asc)
                      .limit(120)
                      .map do |quest|
      {
        id: quest.id,
        title: quest.title.to_s,
        xp: quest.xp.to_i,
        category_id: quest.category_id,
        category_name: quest.category&.name.to_s
      }
    end
    @recommended_quests = recommended_from_pool(@selected_ids)
  rescue StandardError => e
    Rails.logger.warn("Onboarding show failed: #{e.class} #{e.message}")
    @categories = []
    @quest_pool = []
    @recommended_quests = Quest.none
  end

  def update
    category_ids = Array(params[:category_ids]).map(&:to_i).reject(&:zero?).uniq
    if category_ids.empty?
      return redirect_to onboarding_path, alert: "Choisis au moins une categorie pour finaliser l'onboarding."
    end

    current_user.update!(
      onboarding_focus: category_ids.join(","),
      onboarding_completed_at: Time.current
    )

    ProductAnalytics.track(user: current_user, event_name: "onboarding_completed", metadata: { category_ids: category_ids })

    redirect_to dashboard_path, notice: "Onboarding termine. Mission acceptee."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to onboarding_path, alert: "Onboarding impossible: #{e.record.errors.full_messages.join(', ')}"
  rescue StandardError => e
    Rails.logger.warn("Onboarding update failed: #{e.class} #{e.message}")
    redirect_to onboarding_path, alert: "Onboarding temporairement indisponible."
  end

  private

  def recommended_from_pool(category_ids)
    return Quest.none if category_ids.blank?

    ids = Array(category_ids).map(&:to_i).reject(&:zero?).uniq
    return Quest.none if ids.empty?

    Quest.includes(:category).where(category_id: ids).order(xp: :asc).limit(6)
  end
end
