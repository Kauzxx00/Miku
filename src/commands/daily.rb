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

    message.reply(
      "> #{Icons[:gift]} - <@#{discord_id}>, você coletou sua **recompensa diária** e recebeu **R$#{reward}**!"
    )
  rescue => e
    Rubord::Logger.error(
      "Erro no daily para #{discord_id}: #{e.class} - #{e.message}"
    )
  end
end