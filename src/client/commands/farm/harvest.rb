class HarvestCommand < Rubord::CommandBase
  name "colher"
  aliases "harvest"

  def run(message, args)
    discord_id = message.author.id.to_s

    user = User[discord_id]
    return message.reply("Você não possui uma fazenda.") unless user&.farm

    farm  = user.farm
    slots = farm.farm_slots_dataset.order(:id).all

    if args.empty?
      ready_slots = slots.select(&:ready?)

      return message.reply("**#{Icons[:no]} › Nada plantado para colheita.**") if ready_slots.empty?

      grouped = ready_slots.group_by(&:seed_type)
      harvested_text = []

      DB.transaction do
        grouped.each do |type, items|
          quantidade = items.sum(&:quantity)

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

          harvested_text << "#{quantidade}x #{type}"

          items.each(&:clear!)
        end
      end

      return message.reply(
        components: [
          Rubord.Text("**#{Icons[:harvest]} › <@#{discord_id}>, você colheu:**"),
          Rubord.Text(
            harvested_text.map { |h| "> › #{h}" }.join("\n")
          )
        ],
        flags: [:components_v2]
      )
    end

    index = args[0].to_i
    return message.reply("**#{Icons[:no]} › Use: `colher <slot>`**") if index <= 0

    slot = slots[index - 1]

    return message.reply("**#{Icons[:no]} › Slot inválido.**") unless slot
    return message.reply("**#{Icons[:no]} › Nada plantado nesse slot.**") if slot.empty?
    return message.reply("**#{Icons[:time]} › Slot ainda em crescimento.**") unless slot.ready?

    type       = slot.seed_type
    quantidade = slot.quantity

    DB.transaction do
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

      slot.clear!
    end

    message.reply(
      "#{Icons[:harvest]} › Colheita no slot **#{index}.**\n" \
      "> - **Você colheu** `( #{type.capitalize} #{quantidade}x )`"
    )
  rescue => e
    Rubord::Logger.error(
      "Erro no colher para #{discord_id}: #{e.class} - #{e.message}"
    )

    message.reply("Ocorreu um erro ao colher.")
  end
end