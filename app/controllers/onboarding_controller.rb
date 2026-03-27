class OnboardingController < ApplicationController
  before_action :authenticate_user!

  def show
    @categories = Category.order(:name)
    @selected_ids = current_user.onboarding_focus.to_s.split(",").map(&:to_i)
    @recommended_quests = Quest.where(category_id: @selected_ids).order(xp: :asc).limit(6)
  end

  def update
    category_ids = Array(params[:category_ids]).map(&:to_i).reject(&:zero?).uniq
    current_user.update!(
      onboarding_focus: category_ids.join(","),
      onboarding_completed_at: Time.current
    )

    ProductAnalytics.track(user: current_user, event_name: "onboarding_completed", metadata: { category_ids: category_ids })

    redirect_to dashboard_path, notice: "Onboarding termine. Mission acceptee."
  end
end
