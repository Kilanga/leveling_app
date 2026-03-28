namespace :simulation do
  desc "Create or refresh bots with quest progression and cosmetics. Usage: rake simulation:seed_bots[20,8,25]"
  task :seed_bots, [ :count, :min_quests, :max_quests ] => :environment do |_t, args|
    count = (args[:count] || 20).to_i
    min_quests = (args[:min_quests] || 8).to_i
    max_quests = (args[:max_quests] || 25).to_i

    if count <= 0
      puts "Count must be > 0"
      next
    end

    if min_quests <= 0 || max_quests < min_quests
      puts "Invalid quest bounds: min=#{min_quests}, max=#{max_quests}"
      next
    end

    avatars = [
      "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.48_-_A_digital_painting_of_a_male_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._He_wears_a_simple_slightly_wo_qhnmid.webp",
      "https://res.cloudinary.com/dqpfnffmi/image/upload/v1739664484/DALL_E_2025-02-16_01.07.50_-_A_digital_painting_of_a_female_warrior_in_the_style_of_Solo_Leveling_at_level_1_looking_relatively_weak_but_determined._She_wears_a_simple_slightly_x4zdiw.webp"
    ]

    quests = Quest.includes(:category).to_a
    if quests.empty?
      puts "No quests found. Seed quests first."
      next
    end

    frame_items = ShopItem.where(item_type: "profile_frame").to_a
    xp_theme_items = ShopItem.where(item_type: "xp_theme").to_a
    card_items = ShopItem.where(item_type: "profile_card").to_a
    avatar_items = ShopItem.where(item_type: "cosmetic").to_a
    title_items = ShopItem.where(item_type: "title").where.not(rarity: "common").to_a

    puts "Creating/updating #{count} bots..."

    bots = []
    total_completions = 0

    count.times do |i|
      idx = i + 1
      pseudo = format("bot_hunter_%02d", idx)
      email = format("bot+%02d@arnaudlothe.site", idx)

      user = User.find_or_initialize_by(email: email)
      is_new = user.new_record?

      user.assign_attributes(
        pseudo: pseudo,
        password: "Password123!",
        password_confirmation: "Password123!",
        avatar: avatars.sample,
        profile_completed: true,
        coins: [ user.coins.to_i, 1200 ].max,
        confirmed_at: user.confirmed_at || Time.current
      )

      user.save!

      target_completions = rand(min_quests..max_quests)
      selected_quests = quests.sample([ target_completions, quests.size ].min)
      completed_for_user = 0

      selected_quests.each do |quest|
        user_quest = user.user_quests.find_or_initialize_by(quest: quest)
        user_quest.assign_attributes(
          progress: 0,
          completed: false,
          active: true,
          completed_count: user_quest.completed_count.to_i
        )
        user_quest.save!

        gained_xp = XpAwarder.complete_user_quest!(user_quest)
        completed_for_user += 1 if gained_xp
      rescue StandardError => e
        puts "[#{pseudo}] quest #{quest.id} skipped: #{e.class} #{e.message}"
      end

      user.increment!(:coins, rand(200..800))

      [ frame_items, xp_theme_items, card_items, avatar_items, title_items ].each do |pool|
        next if pool.empty?

        pool.sample(rand(1..[ 2, pool.size ].min)).each do |item|
          user.user_items.find_or_create_by!(shop_item: item)
        end
      end

      user.reload
      user.activate_cosmetic(user.shop_items.where(item_type: "profile_frame").sample) if frame_items.any?
      user.activate_cosmetic(user.shop_items.where(item_type: "xp_theme").sample) if xp_theme_items.any?
      user.activate_cosmetic(user.shop_items.where(item_type: "profile_card").sample) if card_items.any?
      user.activate_avatar(user.shop_items.where(item_type: "cosmetic").sample) if avatar_items.any?
      user.activate_title(user.shop_items.where(item_type: "title").sample) if title_items.any?

      total_completions += completed_for_user
      bots << user

      status = is_new ? "created" : "updated"
      puts "- #{pseudo} (#{status}): quests_completed=#{completed_for_user}, xp=#{user.xp}, coins=#{user.coins}"
    end

    avg_xp = bots.empty? ? 0 : (bots.sum(&:xp).to_f / bots.size).round(1)
    avg_levels = if bots.empty?
      0
    else
      (bots.sum { |u| u.user_stats.sum(:level) }.to_f / bots.size).round(1)
    end

    puts ""
    puts "Done."
    puts "Bots: #{bots.size}"
    puts "Total quest completions: #{total_completions}"
    puts "Average XP: #{avg_xp}"
    puts "Average sum of category levels: #{avg_levels}"
  end
end
