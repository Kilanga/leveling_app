class OnboardingController < ApplicationController
  before_action :authenticate_user!
  MAX_TUTORIAL_QUESTS = 6

  def show
    @categories = []
    @selected_ids = current_user.onboarding_category_ids
    @quest_pool = []
    @recommended_quests = Quest.none
    @selected_quest_ids = current_user.user_quests.where(active: true).order(updated_at: :desc).limit(MAX_TUTORIAL_QUESTS).pluck(:quest_id)

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
    @selected_quest_ids &= @recommended_quests.map(&:id)
  rescue StandardError => e
    Rails.logger.warn("Onboarding show failed: #{e.class} #{e.message}")
    @categories = []
    @quest_pool = []
    @recommended_quests = Quest.none
    @selected_quest_ids = []
  end

  def update
    category_ids = Array(params[:category_ids]).map(&:to_i).reject(&:zero?).uniq
    quest_ids = Array(params[:quest_ids]).map(&:to_i).reject(&:zero?).uniq.first(MAX_TUTORIAL_QUESTS)

    if category_ids.empty?
      return redirect_to onboarding_path, alert: "Choisis au moins une categorie pour finaliser l'onboarding."
    end

    ActiveRecord::Base.transaction do
      current_user.update!(
        onboarding_focus: category_ids.join(","),
        onboarding_completed_at: Time.current
      )
      activate_selected_quests!(category_ids, quest_ids)
    end

    ProductAnalytics.track(user: current_user, event_name: "onboarding_completed", metadata: { category_ids: category_ids, quest_ids: quest_ids })

    message = if quest_ids.any?
      "Tutoriel termine. #{quest_ids.size} mission(s) ajoutee(s) a ton suivi."
    else
      "Tutoriel termine. Tu pourras ajouter des missions quand tu veux."
    end
    redirect_to dashboard_path, notice: message
  rescue ActiveRecord::RecordInvalid => e
    redirect_to onboarding_path, alert: "Tutoriel impossible: #{e.record.errors.full_messages.join(', ')}"
  rescue StandardError => e
    Rails.logger.warn("Onboarding update failed: #{e.class} #{e.message}")
    redirect_to onboarding_path, alert: "Tutoriel temporairement indisponible."
  end

  private

  def recommended_from_pool(category_ids)
    return Quest.none if category_ids.blank?

    ids = Array(category_ids).map(&:to_i).reject(&:zero?).uniq
    return Quest.none if ids.empty?

    Quest.includes(:category).where(category_id: ids).order(xp: :asc).limit(6)
  end

  def activate_selected_quests!(category_ids, quest_ids)
    return if quest_ids.blank?

    valid_ids = Quest.where(id: quest_ids, category_id: category_ids).limit(MAX_TUTORIAL_QUESTS).pluck(:id)
    valid_ids.each do |quest_id|
      user_quest = current_user.user_quests.find_or_initialize_by(quest_id: quest_id)
      user_quest.progress = 0 if user_quest.new_record?
      user_quest.completed_count = 0 if user_quest.new_record?
      user_quest.completed = false if user_quest.new_record?
      user_quest.active = true
      user_quest.save!
    end
  end
end
