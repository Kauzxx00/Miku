require_relative "../structs/emojis.rb"

class DailyCommand < Rubord::CommandBase
  name "daily"

  DAILY_COOLDOWN ||= 24 * 60 * 60

  def run(message, _args)
    discord_id = message.author.id.to_s
    now = Time.now

    user = User[discord_id] || User.create(id: discord_id)

    if user.daily_claimed_at && (now - user.daily_claimed_at) < DAILY_COOLDOWN
      remaining = user.daily_claimed_at + DAILY_COOLDOWN

      return message.reply(
        "> #{Icons[:time]} - <@#{discord_id}>, você já coletou sua **recompensa diária**. Volte **<t:#{remaining.to_i}:R>**."
      )
    end

    reward = rand(100..500)

    rewards = {
      "beterraba" => rand(1..3),
      "batata"    => rand(1..3)
    }

    DB.transaction do
      user.update(
        money: user.money + reward,
        daily_claimed_at: now
      )

      rewards.each do |type, qty|
        seed = user.seeds_dataset.first(seed_type: type)

        if seed
          seed.update(quantity: seed.quantity + qty)
        else
          Seed.create(
            user_id: user.id,
            seed_type: type,
            quantity: qty
          )
        end
      end
    end

    message.reply(
      components: [
        Rubord.Text("> #{Icons[:gift]} - <@#{discord_id}>, você coletou sua **recompensa diária** e recebeu **R$#{reward}**!"),
        Rubord.Separator(divider: true, spacing: :small),
        Rubord.Text("-# Volte em")
      ],
      flags: [:components_v2]
    )
  rescue => e
    Rubord::Logger.error(
      "Erro no daily para #{discord_id}: #{e.class} - #{e.message}"
    )
  end
end