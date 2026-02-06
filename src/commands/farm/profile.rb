require_relative "../../structs/emojis.rb"

class ProfileCommand < Rubord::CommandBase
  name "profile"

  def run(message, _args)
    discord_id = message.author.id.to_s
    user = User.find_or_create_by(_id: discord_id)
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

    slots_text =
      if user.farm_slots.any?
        user.farm_slots.map.with_index do |slot, i|
          if slot.empty?
            "🟫 Slot #{i + 1}: vazio"
          elsif slot.ready?
            "🌾 Slot #{i + 1}: pronto para colher"
          elsif slot.dead?
            "💀 Slot #{i + 1}: planta morta"
          else
            "🌱 Slot #{i + 1}: #{slot.seed_type} <t:#{slot.harvest_at.to_i}:R>"
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
    Rubord::Logger.error("Erro no profile: #{e.class} - #{e.message}")
  end
end
