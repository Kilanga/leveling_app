class OnboardingController < ApplicationController
  before_action :authenticate_user!

  def show
    @categories = []
    @selected_ids = current_user.onboarding_category_ids
    @recommended_quests = Quest.none

    return unless feature_tables_ready?(:categories, :quests)

    @categories = Category.order(:name)
    @recommended_quests = Quest.includes(:category).where(category_id: @selected_ids).order(xp: :asc).limit(6) if @selected_ids.any?
  rescue StandardError => e
    Rails.logger.warn("Onboarding show failed: #{e.class} #{e.message}")
    @categories = []
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
end
