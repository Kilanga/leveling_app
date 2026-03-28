require "rails_helper"

RSpec.describe ReferralRewarder do
  let(:avatar_url) do
    "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp"
  end

  def create_user(index)
    User.create!(
      email: "referral_#{index}@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      pseudo: "Referral#{index}",
      avatar: avatar_url,
      profile_completed: true
    )
  end

  it "rewards invitee and inviter only once" do
    inviter = create_user(1)
    invitee = create_user(2)
    invitee.update!(referred_by: inviter)

    first = described_class.claim_if_eligible!(invitee)
    second = described_class.claim_if_eligible!(invitee)

    expect(first[:awarded]).to be(true)
    expect(second[:awarded]).to be(false)

    expect(invitee.reload.free_credits).to eq(ReferralRewarder::INVITEE_REWARD_FREE_CREDITS)
    expect(inviter.reload.free_credits).to eq(ReferralRewarder::INVITER_REWARD_FREE_CREDITS)
    expect(invitee.referral_rewarded_at).to be_present
  end

  it "does not reward users without referrer" do
    user = create_user(3)

    result = described_class.claim_if_eligible!(user)

    expect(result[:awarded]).to be(false)
    expect(user.reload.free_credits).to eq(0)
  end
end
