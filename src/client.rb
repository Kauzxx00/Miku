require "rubord"
require "dotenv/load"
require_relative "structs/mongo.rb"
require_relative "structs/notification.rb"

client = Rubord::Client.new(prefix: ".", intents: [Rubord::Intents.all])

client.on_ready do
  Rubord::Logger.success client.user.tag
  harvest_notifications(client)
end

Rubord::CommandLoader.load("./src/commands", client, client.commands)

client.login(ENV["DISCORD_TOKEN"])