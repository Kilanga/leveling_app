class FriendChallengesController < ApplicationController
  before_action :authenticate_user!

  def create
    challenged = User.find(params[:friend_id])
    unless friends_with?(challenged)
      return redirect_to friends_path, alert: I18n.t('errors.messages.challenge_requires_friend')
    end

    challenge = FriendChallenge.create!(
      challenger: current_user,
      challenged: challenged,
      status: "active",
      starts_at: Time.current,
      ends_at: 48.hours.from_now,
      reward_coins: 80
    )

    InAppNotification.create!(
      user: challenged,
      kind: "challenge_received",
      title: "Nouveau defi ami",
      body: "#{current_user.pseudo} te defie pendant 48h.",
      cta_path: "/friends"
    )

    ProductAnalytics.track(user: current_user, event_name: "friend_challenge_created", metadata: { challenge_id: challenge.id, friend_id: challenged.id })

    redirect_to friends_path, notice: I18n.t('flash.friend_challenge.challenge_launched')
  end

  private

  def friends_with?(user)
    Friendship.accepted.where(user: current_user, friend: user).exists? ||
      Friendship.accepted.where(user: user, friend: current_user).exists?
  end
end
