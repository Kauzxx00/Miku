require "rubord"
require "async"
require "dotenv/load"
require_relative "structs/database.rb"
require_relative "models/user.rb"
require_relative "models/farm.rb"
# require_relative "structs/notification.rb"

client = Rubord::Client.new(prefix: ".", intents: [Rubord::Intents.all])

client.on_ready do
  Rubord::Logger.success client.user.tag
  # harvest_notifications(client)
end

client.on_message do |message|
  if message.content.start_with?("<@#{client.user.id}>")
    message.reply(
      "#{Icons[:notify]} Aoba **fazendeiro**! Eu sou a <@#{client.user.id}>\n" \
      "> - Veja sua **fazenda** com **`m.farm`**\n" \
      "> - Liste meus **comandos** usando **`m.help`**\n"
    )
  end
end

client.on_interaction do |interaction|
  next unless interaction.custom_id.start_with?("plant_slot:")

  user_id = interaction.custom_id.split(":")[1]
  next unless interaction.user.id.to_s == user_id

  context = PlantCommand.get_context(interaction.user.id.to_s)
  next unless context
  
  user = User[user_id]
  slot_index = interaction.values.first.to_i - 1
  farm = user.farm
  slot = farm.farm_slots[slot_index]

  pp slot, slot_index
  if slot.nil? || !slot.empty?
    return interaction.reply(
      content: "> 🚫 Slot inválido ou ocupado.",
      ephemeral: true
    )
  end

  seed = user.seeds.find { |s| s.seed_type == context[:seed_type] }
  seed.update(quantity: seed.quantity - context[:quantity])

  slot.plant!(
    seed_type: context[:seed_type],
    quantity: context[:quantity],
    duration: context[:duration],
    channel_id: context[:channel_id]
  )

  interaction.update(
    components: [
      Rubord.Text(
        "> 🌱 <@#{user_id}> plantou **#{context[:quantity]}x #{context[:seed_type]}**!",
        "> ⏳ Pronto em **#{context[:duration] / 60} minutos**"
      )
    ], flags: [:components_v2]
  )

  Thread.new do
    sleep(context[:duration])

    begin
      refreshed_user = User[user_id]
      next unless refreshed_user

      farm = refreshed_user.farm
      next unless farm

      refreshed_slot = farm.farm_slots[slot_index]
      next unless refreshed_slot
      next unless refreshed_slot.ready?

      channel =
        client.channels.get(context[:channel_id]) ||
        client.fetch_channel(context[:channel_id])

      if channel
        channel.post(
          "> #{Icons[:seeds]} - <@#{user_id}>, sua plantação de **#{refreshed_slot.seed_type}** está pronta para colheita!"
        )
      end
    rescue => e
      Rubord::Logger.error(
        "Erro ao notificar colheita: #{e.message}\n#{e.backtrace.join("\n")}"
      )
    end
  end

  PlantCommand.clear_context(interaction.user.id.to_s)
rescue => e
  Rubord::Logger.error("Erro no plant(interaction): #{e.class} - #{e.full_message}")
end

Rubord::CommandLoader.load("./src/commands", client, client.commands, logCommands: false)

client.login(ENV["DISCORD_TOKEN"])