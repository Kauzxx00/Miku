class FarmCommand < Rubord::CommandBase
  name "farm"
  description "Gerencie sua fazenda, plante e colha suas plantações."
  aliases ["fazenda"]

  SLOTS_PER_TERRAIN = 2

  def run(message, args)
    discord_id = message.author.id.to_s
    page = (args[0] || 1).to_i
    page = 1 if page <= 0

    user = User[discord_id] || User.create(id: discord_id)
    farm = user.farm || create_farm_for(user)

    slots = farm.farm_slots_dataset.order(:id).all

    total_pages = [(slots.size.to_f / SLOTS_PER_TERRAIN).ceil, 1].max
    page = total_pages if page > total_pages

    start = (page - 1) * SLOTS_PER_TERRAIN
    page_slots = slots.slice(start, SLOTS_PER_TERRAIN) || []

    slots_text =
      if page_slots.empty?
        "🟫 Nenhum slot neste terreno"
      else
        page_slots.map.with_index do |slot, i|
          index = start + i + 1

          case slot.status
          when "empty"
            "🟫 Slot #{index}: vazio"
          when "ready"
            "🌾 Slot #{index}: pronto para colher"
          when "dead"
            "💀 Slot #{index}: planta morta"
          else
            "🌱 Slot #{index}: #{slot.seed_type} <t:#{slot.harvest_at.to_i}:R>"
          end
        end
      end

    navigation =
      if total_pages > 1
        Rubord.Text(
          "-# Terreno #{page}/#{total_pages}",
          "-# Use `/farm #{page - 1}` ou `/farm #{page + 1}`"
        )
      end

    container = Rubord.Container(
      Rubord.Text("## #{Icons[:farm]} - Fazenda de ( #{message.author.globalname} )"),
      Rubord.Separator(divider: true, spacing: :small),
      Rubord.Text("-# Acompanhe o crescimento das suas plantações:"),
      Rubord.Text(*slots_text),
      navigation
    )

    message.reply(components: [container], flags: [:components_v2])
  rescue => e
    Rubord::Logger.error("Erro no farm: #{e.class} - #{e.full_message}")
    message.reply("> ❌ Erro ao carregar fazenda.")
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