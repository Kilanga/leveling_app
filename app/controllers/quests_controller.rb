class QuestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.order(:name)
    @selected_category_id = params[:category_id].presence
    @query = params[:query].to_s.strip
    @selected_difficulty = params[:difficulty].presence_in(%w[easy medium hard])
    @selected_sort = params[:sort].presence_in(%w[featured quick big_xp]) || "featured"

    @quests = Quest.includes(:category)

    if @query.present?
      @quests = @quests.where("title ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%")
    end

    if @selected_category_id.present?
      @quests = @quests.where(category_id: @selected_category_id)
    end

    @difficulty_totals = {
      easy: @quests.where("xp <= ?", 80).count,
      medium: @quests.where("xp > ? AND xp <= ?", 80, 150).count,
      hard: @quests.where("xp > ?", 150).count
    }

    case @selected_difficulty
    when "easy"
      @quests = @quests.where("xp <= ?", 80)
    when "medium"
      @quests = @quests.where("xp > ? AND xp <= ?", 80, 150)
    when "hard"
      @quests = @quests.where("xp > ?", 150)
    end

    @quests = case @selected_sort
    when "quick"
      @quests.order(xp: :asc, title: :asc)
    when "big_xp"
      @quests.order(xp: :desc, title: :asc)
    else
      @quests.order(daily_featured: :desc, xp: :asc, title: :asc)
    end

    user_quests = current_user.user_quests.where(quest_id: @quests.select(:id))
    @user_quests_by_quest_id = user_quests.index_by(&:quest_id)
    @active_user_quests = user_quests.includes(quest: :category).where(active: true, completed: false).order(updated_at: :desc)
    @active_user_quests_count = current_user.user_quests.where(active: true, completed: false).count
    @category_totals = Quest.group(:category_id).count

    active_quest_ids = current_user.user_quests.where(active: true).select(:quest_id)
    top_category_ids = current_user.user_stats.order(total_xp: :desc).limit(2).pluck(:category_id)

    @recommended_quests = Quest.includes(:category)
      .where(category_id: top_category_ids)
      .where.not(id: active_quest_ids)
      .order(daily_featured: :desc, xp: :desc)
      .limit(4)

    if @recommended_quests.empty?
      @recommended_quests = Quest.includes(:category)
        .where.not(id: active_quest_ids)
        .order(daily_featured: :desc, xp: :asc)
        .limit(4)
    end
  end

  def show
    @quest = Quest.find(params[:id])
    @user_quest = current_user.user_quests.find_or_initialize_by(quest: @quest)
  end
end
