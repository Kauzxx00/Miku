require "rubord"
require "async"
require "dotenv/load"
require_relative "structs/handlers/interactions.rb"
require_relative "structs/database.rb"
require_relative "structs/emojis.rb"
require_relative "models/user.rb"
require_relative "models/farm.rb"
# require_relative "structs/notification.rb"

client = Rubord::Client.new(prefix: "m.", intents: [Rubord::Intents.all])

client.on_ready do
  Rubord::Logger.success client.user.tag
  # harvest_notifications(client)
end

InteractionRouter.load_handlers("./src/client/interactions", client)
client.on_interaction do |interaction|
  InteractionRouter.run(interaction)
end

Rubord::CommandLoader.load("./src/client/commands/", client, client.commands, logCommands: false)

client.on_message do |message|
  if message.content.start_with?("<@#{client.user.id}>")
    message.reply(
      "#{Icons[:notify]} **–** Aoba **fazendeiro**! Eu sou a <@#{client.user.id}>\n" \
      "> - Veja sua **fazenda** com **`m.farm`**\n" \
      "> - Liste meus **comandos** usando **`m.help`**\n"
    )
  end
end

client.login(ENV["DISCORD_TOKEN"])