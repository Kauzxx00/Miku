class PlantCommand < Rubord::CommandBase
  name "plantar"
  aliases "plant"

  PLANTS ||= {
    "beterraba" => { duration: 90, emoji: "🥕" },
    "batata"    => { duration: 60,  emoji: "🥔" }
  }

  def run(message, args)
    discord_id = message.author.id.to_s

    user   = User[discord_id] || User.create(id: discord_id)
    type   = args[0]
    amount = (args[1] || 1).to_i

    return message.reply("**#{Icons[:no]} › Erro ao utilizar comando.**\n> -# Use: `plantar <tipo> <quantidade>`") unless type

    plant = PLANTS[type]
    seed  = user.seeds_dataset.first(seed_type: type)

    return message.reply("**#{Icons[:no]} › Semente inválida.**") unless plant && seed
    return message.reply("**#{Icons[:no]} › Quantidade inválida.**") if amount <= 0
    return message.reply("**#{Icons[:no]} › Sementes insuficientes.**") if seed.quantity < amount

    farm  = user.farm || create_farm_for(user)
    slots = farm.farm_slots_dataset.order(:id).all

    slot = slots.find { |s| s.empty? && s.capacity >= amount }

    return message.reply("**#{Icons[:no]} › Nenhum slot disponível com essa capacidade.**") unless slot

    DB.transaction do
      seed.update(quantity: seed.quantity - amount)

      slot.plant!(
        seed_type: type,
        quantity: amount,
        duration: plant[:duration],
        channel_id: message.channel.id
      )
    end

    message.reply(
      "> **#{Icons[:seeds]} › Você plantou** `( #{type} #{amount}x )`\n" \
      "> **#{Icons[:time]} › Pronto** <t:#{(Time.now + plant[:duration]).to_i}:R>"
    )

    Thread.new do
      sleep(plant[:duration])

      refreshed_user = User[discord_id]
      next unless refreshed_user

      farm = refreshed_user.farm
      next unless farm

      refreshed_slot = farm.farm_slots_dataset.order(:id).all.find { |s| s.id == slot.id }
      next unless refreshed_slot&.ready?

      channel =
        @client.channels.get(message.channel.id) ||
        @client.fetch_channel(message.channel.id)

      channel&.post(
        "> #{Icons[:seeds]} › <@#{discord_id}>, sua plantação de **#{type}** está pronta!"
      )
    end
  end

  private

  def create_farm_for(user)
    farm = Farm.create(id: user.id)

    4.times do
      FarmSlot.create(farm_id: farm.id)
    end

    farm
  end
end