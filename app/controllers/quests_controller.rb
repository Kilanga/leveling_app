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

    @difficulty_bounds = difficulty_bounds_for(@quests)
    easy_max = @difficulty_bounds[:easy_max]
    medium_max = @difficulty_bounds[:medium_max]

    @difficulty_totals = {
      easy: @quests.where("xp <= ?", easy_max).count,
      medium: @quests.where("xp > ? AND xp <= ?", easy_max, medium_max).count,
      hard: @quests.where("xp > ?", medium_max).count
    }

    case @selected_difficulty
    when "easy"
      @quests = @quests.where("xp <= ?", easy_max)
    when "medium"
      @quests = @quests.where("xp > ? AND xp <= ?", easy_max, medium_max)
    when "hard"
      @quests = @quests.where("xp > ?", medium_max)
    end

    @quests = case @selected_sort
    when "quick"
      @quests.order(xp: :asc, title: :asc)
    when "big_xp"
      @quests.order(xp: :desc, title: :asc)
    else
      @quests.order(xp: :asc, title: :asc)
    end

    user_quests = current_user.user_quests.where(quest_id: @quests.select(:id))
    @user_quests_by_quest_id = user_quests.index_by(&:quest_id)
    @active_user_quests = user_quests.includes(quest: :category).where(active: true, completed: false).order(updated_at: :desc)
    @active_user_quests_count = current_user.user_quests.where(active: true, completed: false).count
    @category_totals = Quest.group(:category_id).count

    recommendation_entries = QuestRecommender.call(user: current_user, limit: 4)
    @recommended_quests = recommendation_entries.map { |entry| entry[:quest] }
    @recommendation_reason_by_quest_id = recommendation_entries.to_h { |entry| [ entry[:quest].id, entry[:reason] ] }
  end

  def show
    @quest = Quest.find(params[:id])
    @user_quest = current_user.user_quests.find_or_initialize_by(quest: @quest)
  end

  private

  def difficulty_bounds_for(scope)
    xp_values = scope.where.not(xp: nil).order(:xp).pluck(:xp)
    return { easy_max: 120, medium_max: 260 } if xp_values.empty?

    easy_index = ((xp_values.length - 1) * 0.33).floor
    medium_index = ((xp_values.length - 1) * 0.66).floor

    easy_max = xp_values[easy_index]
    medium_max = [ xp_values[medium_index], easy_max + 1 ].max

    { easy_max: easy_max, medium_max: medium_max }
  end
end
