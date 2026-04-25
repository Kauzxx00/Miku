class HarvestAll < Interactions::Base
  name "harvest_all"
  authorOnly? true

  def run(interaction)
    discord_id = interaction.user.id.to_s

    user = User[discord_id]
    return interaction.reply("Você não possui uma fazenda.") unless user&.farm

    farm = user.farm
    slots = farm.farm_slots_dataset.all

    ready_slots = slots.select(&:ready?)

    if ready_slots.empty?
      return interaction.reply("Nada pronto para colher.")
    end

    grouped = ready_slots.group_by { |s| s.seed_type }

    harvested_text = []

    DB.transaction do
      grouped.each do |type, items|
        quantidade = items.sum { |s| s.quantity.to_i }

        seed = user.seeds_dataset.first(seed_type: type)

        if seed
          seed.update(quantity: seed.quantity + quantidade)
        else
          Seed.create(
            user_id: user.id,
            seed_type: type,
            quantity: quantidade
          )
        end

        harvested_text << "`( #{type.capitalize} #{quantidade}x )`"

        items.each do |slot|
          slot.clear!
        end
      end
    end

    interaction.reply(
      components: [
        Rubord.Text(">>> **#{Icons[:harvest]} › <@#{discord_id}>, você colheu:**",
          harvested_text.map { |h| "- × #{h}" }.join("\n")
        )
      ],
      flags: [:components_v2]
    )

  rescue => e
    Rubord::Logger.error(
      "Erro no harvest_all para #{discord_id}: #{e.class} - #{e.full_message}"
    )

    interaction.reply("Ocorreu um erro ao colher.")
  end
end