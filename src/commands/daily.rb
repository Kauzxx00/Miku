require_relative "../structs/emojis.rb"

class DailyCommand < Rubord::CommandBase
  name "daily"

  DAILY_COOLDOWN = 24 * 60 * 60

  def run(message, _args)
    discord_id = message.author.id.to_s
    now = Time.now

    user = User.find_or_create_by(_id: discord_id)

    if user.daily_claimed_at && (now - user.daily_claimed_at) < DAILY_COOLDOWN
      remaining = user.daily_claimed_at + DAILY_COOLDOWN

      return message.reply(
        "> #{Icons[:time]} - <@#{discord_id}>, você já coletou sua **recompensa diária**. Volte **<t:#{remaining.to_i}:R>**."
      )
    end

    reward = rand(100..500)
    user.inc(money: reward)
    user.update!(daily_claimed_at: now)
    rewards = {
      "beet" => rand(1..3),
      "potato" => rand(1..3)
    }

    rewards.each do |type, qty|
      seed = user.seeds.find { |s| s.seed_type == type.to_s }
      if seed
        seed.inc(quantity: qty)
      else
        user.seeds << Seed.new(seed_type: type.to_s, quantity: qty)
      end
    end

    message.reply(
      "> #{Icons[:gift]} - <@#{discord_id}>, você coletou sua **recompensa diária** e recebeu **R$#{reward}**!"
    )
  rescue => e
    Rubord::Logger.error(
      "Erro no daily para #{discord_id}: #{e.class} - #{e.message}"
    )
  end
end