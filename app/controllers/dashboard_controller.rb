class DashboardController < ApplicationController
  before_action :authenticate_user!

  WEEKLY_REUSE_WINDOW = 6.weeks
  DAILY_TARGET = 2
  DAILY_CHEST_REWARD_FREE_CREDITS = 35

  def claim_daily_chest
    if completed_today_count < DAILY_TARGET
      redirect_to dashboard_path, alert: "Tu dois valider #{DAILY_TARGET} quetes aujourd'hui pour ouvrir le coffre quotidien."
      return
    end

    if daily_chest_claimed_today?
      redirect_to dashboard_path, alert: "Coffre quotidien deja reclame aujourd'hui."
      return
    end

    claim_daily_chest_reward!
    ProductAnalytics.track(user: current_user, event_name: "daily_chest_claimed", metadata: { reward_free_credits: DAILY_CHEST_REWARD_FREE_CREDITS })

    redirect_to dashboard_path, notice: "Coffre quotidien ouvert: +#{DAILY_CHEST_REWARD_FREE_CREDITS} credits gratuits."
  end

  def index
    Faction.bootstrap_defaults!
    DailyContractBoard.ensure_for_today!

    @daily_login_claim = current_user.claim_daily_login_bonus!

    active_weekly_quest = ensure_single_active_global_weekly_quest!
    attach_current_user_to_active_weekly_quest!(active_weekly_quest)

    @weekly_quests = current_user.user_weekly_quests
      .joins(:weekly_quest)
      .where("weekly_quests.valid_until >= ?", Time.current)
      .includes(:weekly_quest)

    @user_quests = current_user.user_quests.includes(:quest)
    @stats = current_user.user_stats.includes(:category)

    @stats.each do |stat|
      recalculated_level, recalculated_xp = XpCalculator.calculate_level_and_xp(stat.total_xp)

      if stat.level != recalculated_level || stat.xp != recalculated_xp
        stat.update(level: recalculated_level, xp: recalculated_xp)
      end
    end

    @stats_data = @stats.map do |stat|
      {
        name: stat.category.name,
        level: stat.level,
        xp: stat.xp,
        xp_needed: XpCalculator.xp_needed_for_next_level(stat.level)
      }
    end

    @total_level = @stats.sum(&:level)
    @weekly_streak_count = current_user.weekly_streak_count.to_i
    @weekly_streak_last_completed_on = current_user.weekly_streak_last_completed_on
    @daily_target = DAILY_TARGET
    @completed_today_count = completed_today_count
    @daily_progress_percent = [ (@completed_today_count.to_f / @daily_target * 100).round, 100 ].min
    @daily_chest_claimed_today = daily_chest_claimed_today?
    @daily_chest_reward_free_credits = DAILY_CHEST_REWARD_FREE_CREDITS
    @friends_activity = recent_friends_activity

    cycle_anchor = FactionInfluence.current_cycle_anchor_date
    previous_cycle_anchor = cycle_anchor - 7.days
    @next_faction_reset_at = FactionInfluence.next_reset_at
    @faction_reset_countdown = format_countdown(@next_faction_reset_at)
    @can_change_faction = current_user.can_change_faction?
    @faction_switch_available_at = current_user.faction_switch_available_at
    @factions = Faction.order(:name)

    today_scores = FactionInfluence.where(on_date: cycle_anchor)
      .select("faction_id, SUM(points) AS points")
      .group(:faction_id)

    @faction_scores_today = Faction
      .joins("LEFT JOIN (#{today_scores.to_sql}) AS today_scores ON today_scores.faction_id = factions.id")
      .select("factions.*, COALESCE(today_scores.points, 0) AS today_points")
      .order(Arel.sql("today_points DESC, factions.name ASC"))
    @leading_faction = @faction_scores_today.first

    previous_scores = FactionInfluence.where(on_date: previous_cycle_anchor)
      .select("faction_id, SUM(points) AS points")
      .group(:faction_id)

    previous_scores = Faction
      .joins("LEFT JOIN (#{previous_scores.to_sql}) AS previous_scores ON previous_scores.faction_id = factions.id")
      .select("factions.*, COALESCE(previous_scores.points, 0) AS previous_points")
      .order(Arel.sql("previous_points DESC, factions.name ASC"))
    @previous_winning_faction = previous_scores.first
    @previous_winning_participants =
      if @previous_winning_faction.present? && @previous_winning_faction.try(:previous_points).to_i > 0
        FactionContribution.includes(:user)
          .where(faction: @previous_winning_faction, on_date: previous_cycle_anchor)
          .order(points: :desc, created_at: :asc)
      else
        []
      end

    today_contracts = DailyContract.for_today
    today_contracts.each do |contract|
      current_user.user_daily_contracts.find_or_create_by!(daily_contract: contract)
    end
    @daily_contract_offers = current_user.user_daily_contracts.includes(:daily_contract)
      .joins(:daily_contract)
      .where(daily_contracts: { active_on: Time.zone.today })
      .order("daily_contracts.reward_coins DESC")
    @active_daily_contract = @daily_contract_offers.find { |entry| entry.accepted? }

    respond_to do |format|
      format.html
      format.json { render json: @stats_data }
    end
  end

  private

  def completed_today_count
    current_user.user_quests
      .where(completed: true)
      .where(updated_at: Time.zone.today.all_day)
      .count
  end

  def daily_chest_claimed_today?
    current_user.purchases.exists?(transaction_id: daily_chest_transaction_id)
  end

  def daily_chest_transaction_id
    "daily-chest-#{current_user.id}-#{Time.zone.today.iso8601}"
  end

  def claim_daily_chest_reward!
    ActiveRecord::Base.transaction do
      current_user.add_free_credits!(DAILY_CHEST_REWARD_FREE_CREDITS)
      current_user.purchases.create!(
        amount: DAILY_CHEST_REWARD_FREE_CREDITS,
        item_type: "daily_chest",
        status: "completed",
        transaction_id: daily_chest_transaction_id
      )
    end
  end

  def recent_friends_activity
    sent_friend_ids = current_user.friendships.accepted.pluck(:friend_id)
    received_friend_ids = Friendship.accepted.where(friend_id: current_user.id).pluck(:user_id)
    friend_ids = (sent_friend_ids + received_friend_ids).uniq
    return [] if friend_ids.empty?

    ProductEvent.where(user_id: friend_ids)
      .where(event_name: %w[quest_completed weekly_quest_completed daily_chest_claimed friend_request_accepted])
      .includes(:user)
      .order(created_at: :desc)
      .limit(8)
  end

  def ensure_single_active_global_weekly_quest!
    active_quests = WeeklyQuest.where("valid_until >= ?", Time.current).order(valid_until: :desc, created_at: :desc)
    current_active = active_quests.first

    unless current_active
      recent_titles = WeeklyQuest.where("created_at >= ?", WEEKLY_REUSE_WINDOW.ago)
                                 .pluck(:title)
                                 .map { |title| title.to_s.sub(/\AHebdo:\s*/, "") }
                                 .uniq

      source_scope = Quest.includes(:category)
      source_scope = source_scope.where.not(title: recent_titles) if recent_titles.any?

      source_quest = source_scope.order(Arel.sql("RANDOM()")).first
      source_quest ||= Quest.includes(:category).order(Arel.sql("RANDOM()")).first
      return nil unless source_quest

      current_active = WeeklyQuest.create!(
        title: "Hebdo: #{source_quest.title}",
        description: source_quest.description.presence || "Complete cette quete hebdomadaire pour un gros bonus.",
        xp_reward: [ source_quest.xp.to_i * 2, 300 ].max,
        category: source_quest.category,
        valid_until: 7.days.from_now
      )
    end

    duplicate_ids = active_quests.where.not(id: current_active.id).pluck(:id)
    if duplicate_ids.any?
      WeeklyQuest.where(id: duplicate_ids).update_all(valid_until: 1.second.ago)
    end

    current_active
  end

  def attach_current_user_to_active_weekly_quest!(weekly_quest)
    return unless weekly_quest

    current_user.user_weekly_quests.find_or_create_by!(weekly_quest: weekly_quest)
  end

  def format_countdown(target_time)
    remaining = (target_time - Time.current).to_i
    return "maintenant" if remaining <= 0

    days = remaining / 86_400
    hours = (remaining % 86_400) / 3_600
    minutes = (remaining % 3_600) / 60

    "#{days}j #{hours}h #{minutes}m"
  end
end
