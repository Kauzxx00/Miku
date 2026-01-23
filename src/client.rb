require "rubord"
require "dotenv/load"
# require_relative "structs/mongo.rb"
require_relative "structs/notification.rb"

client = Rubord::Client.new(prefix: ".", intents: [Rubord::Intents.all])

client.on_ready do
  Rubord::Logger.success client.user.tag
  harvest_notifications(client)
end

client.on_message do |message|
  if message.content.start_with?("<@#{client.user.id}>")
    message.reply(
      "> #{Icons[:notify]} - Aoba **fazendeiro**, meu nome é `Miku` e estou em fase beta.\n" +
      "> Meu **prefixo** aqui é **`m.`**. Utilize **`m.help`** para ver todos os meus **comandos**.",
    )

    Rubord.Container
  end
end

Rubord::CommandLoader.load("./src/commands", client, client.commands)

client.login(ENV["DISCORD_TOKEN"])