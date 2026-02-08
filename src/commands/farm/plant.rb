class PlantCommand < Rubord::CommandBase
  name "plantar"

  PLANTS ||= {
    "beterraba" => { duration: 600, emoji: "🥕" },
    "batata"    => { duration: 60,  emoji: "🥔" }
  }

  @contexts ||= {}

  class << self
    attr_reader :contexts

    def set_context(user_id, data)
      @contexts[user_id] = data
    end

    def get_context(user_id)
      @contexts[user_id]
    end

    def clear_context(user_id)
      @contexts.delete(user_id)
    end
  end

  def run(message, args)
    discord_id = message.author.id.to_s

    user = User[discord_id] || User.create(id: discord_id)

    type   = args[0]
    amount = (args[1] || 1).to_i

    return message.reply("> 🌱 Use: `plantar <tipo> <quantidade>`") unless type
    return message.reply("> ❌ Quantidade inválida.") if amount <= 0

    plant = PLANTS[type]
    return message.reply("> ❌ Planta inválida.") unless plant

    seed = user.seeds_dataset.first(seed_type: type)
    return message.reply("> ❌ Você não possui essa semente.") unless seed
    return message.reply("> ❌ Sementes insuficientes.") if seed.quantity < amount

    farm = user.farm || create_farm_for(user)
    slots = farm.farm_slots

    return message.reply("> ❌ Você não possui slots de fazenda.") if slots.empty?

    empty_slot = slots.find(&:empty?)
    return message.reply("> ❌ Você não possui slots vazios.") unless empty_slot

    insufficient = slots.any? { |f| f.capacity < amount }
    return message.reply("> ❌ Você não possui slots com capacidade suficiente.") if insufficient

    PlantCommand.set_context(discord_id, {
      seed_type:  type,
      quantity:  amount,
      duration:  plant[:duration],
      channel_id: message.channel.id.to_s
    })

    menu = Rubord.SelectMenu(
      custom_id: "plant_slot:#{discord_id}",
      placeholder: "🌱 Escolha um slot"
    )

    slots.each_with_index do |slot, index|
      status_emoji = {
        "empty"   => "⬜",
        "growing" => "🌱",
        "ready"   => "🌾",
        "dead"    => "💀"
      }[slot.status]

      menu.add_option(
        label: "Slot #{index + 1}",
        value: slot.id.to_s,
        description: "Status: #{slot.status}",
        emoji: { name: status_emoji }
      )
    end

    message.reply(
      components: [
        Rubord.Container(
          Rubord.Text("## 🌱 Plantar #{type}"),
          Rubord.Separator,
          Rubord.ActionRow(menu)
        )
      ],
      flags: [:components_v2]
    )
  rescue => e
    Rubord::Logger.error("Erro no plantar(menu): #{e.class} - #{e.message}")
    message.reply("> ❌ Erro ao iniciar plantio.")
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