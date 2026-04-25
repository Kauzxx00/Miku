class ProfileCommand < Rubord::CommandBase
  name "profile"
  aliases "perfil"

  def run(message, _args)
    discord_id = message.author.id.to_s
    user = User[discord_id] || User.create(id: discord_id)
    now = Time.now

    daily_text =
      if user.daily_claimed_at
        next_daily = user.daily_claimed_at + DailyCommand::DAILY_COOLDOWN
        now >= next_daily ?
          "**Disponível**" :
          "<t:#{next_daily.to_i}:R>"
      else
        "**Disponível**"
      end

    farm = user.farm || create_farm_for(user)
    slots = farm.farm_slots_dataset.all
    ready_slots = slots.select(&:ready?).count
    growing_slots = slots.select(&:growing?).count

    container = Rubord.Container(
      Rubord.Text("### × Perfil de [@#{message.author.globalname}](https://discord.com/users/#{message.author.id})"),
      Rubord.Separator(divider: true, spacing: :small),

      Rubord.Text("**#{Icons[:money]} - Economias**",
        "> - **Saldo:** `( R$#{user.money} )`",
        "> - **Daily:** #{daily_text}"
      ),
      Rubord.Separator(spacing: :small),

      Rubord.Text("**#{Icons[:farm]} - Fazenda**",
        "> - **Nível:** `( #{farm.level} )`",
        "> - **Slots prontos para colher:** `( #{ready_slots}/#{growing_slots} )`"
      )
    )

    message.reply(components: [container], flags: [:components_v2])
  rescue => e
    Rubord::Logger.error("Erro no profile: #{e.class} - #{e.full_message}")
  end

  private

  def create_farm_for(user)
    farm = Farm.create(id: user.id)

    3.times do
      FarmSlot.create(farm_id: farm.id)
    end

    farm
  end
end
