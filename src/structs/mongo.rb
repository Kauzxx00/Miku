require "mongoid"

require_relative "../models/user.rb"
require_relative "../models/seed.rb"
require_relative "../models/farm_slot.rb"
require_relative "../models/fertilizer.rb"

Mongoid.configure do |config|
  config.clients.default = {
    uri: ENV["MONGO_URL"],
    options: {
      server_selection_timeout: 5,
      connect_timeout: 5
    }
  }
end

begin
  Mongoid::Clients.default.database.command(ping: 1)
  Rubord::Logger.success "Conectado com sucesso ao MongoDB Atlas!"
rescue Mongo::Error::NoServerAvailable => e
  Rubord::Logger.error "Falha ao conectar ao MongoDB: #{e.message}"
  exit(1)
end