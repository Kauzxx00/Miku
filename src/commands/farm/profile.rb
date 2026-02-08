require_relative "../../structs/emojis.rb"

class ProfileCommand < Rubord::CommandBase
  name "profile"

  def run(message, _args)
    discord_id = message.author.id.to_s
    user = User[discord_id] || User.create(id: discord_id)
    now = Time.now

    daily_text =
      if user.daily_claimed_at
        next_daily = user.daily_claimed_at + DailyCommand::DAILY_COOLDOWN
        now >= next_daily ?
          "Disponível" :
          "<t:#{next_daily.to_i}:R>"
      else
        "Disponível"
      end

    farm = user.farm || create_farm_for(user)
    slots = farm.farm_slots.sort_by(&:id)

    slots_text =
      if slots.any?
        slots.map.with_index do |slot, i|
          n = i + 1

          if slot.empty?
            "🟫 Slot #{n}: vazio"
          elsif slot.ready?
            "🌾 Slot #{n}: pronto para colher"
          elsif slot.dead?
            "💀 Slot #{n}: planta morta"
          else
            "🌱 Slot #{n}: #{slot.seed_type} <t:#{slot.harvest_at.to_i}:R>"
          end
        end.join("\n")
      else
        "> Nenhum slot comprado"
      end

    container = Rubord.Container(
      Rubord.Text("## 👨‍🌾 Perfil da Fazenda"),
      Rubord.Separator(divider: true, spacing: :small),

      Rubord.Text("- **Economia**", "> Saldo: **R$#{user.money}**\n> Daily: #{daily_text}"),
      Rubord.Separator(spacing: :small),

      Rubord.Text("- **Slots**", slots_text)
    )

    message.reply(components: [container], flags: [:components_v2])
  rescue => e
    Rubord::Logger.error("Erro no profile: #{e.class} - #{e.full_message}")
  end

  private

  def create_farm_for(user)
    farm = Farm.create(id: user.id)

    2.times do
      FarmSlot.create(farm_id: farm.id)
    end

    farm
  end
end
