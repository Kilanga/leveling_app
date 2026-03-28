class UserQuestsController < ApplicationController
  before_action :authenticate_user!

  def create
    quest = Quest.find(params[:quest_id])
    user_quest = current_user.user_quests.find_or_initialize_by(quest: quest)

    if user_quest.new_record?
      user_quest.assign_attributes(progress: 0, completed: false, active: true, completed_count: 0)
      user_quest.save
      flash[:notice] = "Quête ajoutée avec succès !"

    elsif !user_quest.active?
      if user_quest.locked_until_daily_reset?
        flash[:alert] = "Cette quete n'est pas encore disponible."
      else
        # Si la quête était désactivée, la réactiver et réinitialiser `completed: false`
        user_quest.update(active: true, completed: false)
        flash[:notice] = "Quête réactivée avec succès !"
      end

    else
      flash[:alert] = "Tu suis déjà cette quête."
    end

    redirect_to quests_path
  end

  def destroy
    user_quest = current_user.user_quests.find(params[:id])

    if user_quest.update(active: false)
      flash[:notice] = "Quête retirée avec succès."
    else
      flash[:alert] = "Impossible de retirer la quête."
    end

    redirect_to quests_path
  end

  def update
    @user_quest = current_user.user_quests.find(params[:id])

    case params[:action_type]
    when "complete"
      quest_title = @user_quest.quest.title
      gained_xp = XpAwarder.complete_user_quest!(@user_quest)
      if gained_xp
        @user_quest.reload
        if current_user.faction.present?
          FactionInfluence.add_points!(faction: current_user.faction, points: 1)
          FactionContribution.add_points!(faction: current_user.faction, user: current_user, points: 1)
        end
        UserDailyContract.progress_for_user!(current_user)
        referral_result = ReferralRewarder.claim_if_eligible!(current_user)
        streak = WeeklyStreakTracker.register_completion!(current_user)
        ProductAnalytics.track(
          user: current_user,
          event_name: "quest_completed",
          metadata: { quest_id: @user_quest.quest_id, xp: gained_xp, streak: streak }
        )
        flash[:streak_up_quest_title] = quest_title
        flash[:streak_up_value] = @user_quest.completed_count.to_i
        referral_note = referral_result[:awarded] ? " Bonus parrainage: +#{referral_result[:invitee_reward]} Fragments." : ""
        redirect_to root_path, notice: "Quete completee ! XP ajoute : #{gained_xp}.#{referral_note}"
      else
        redirect_to root_path, alert: "Cette quête n'est plus active."
      end
    when "unfollow"
      @user_quest.update(active: false)
      redirect_to root_path, notice: "Quête supprimée de votre liste."
    else
      redirect_to root_path, alert: "Action de quete non reconnue."
    end
  end
end
