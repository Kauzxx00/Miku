require "dotenv/load"
require "sequel"

begin
  DB = Sequel.connect(
    ENV["SUPABASE_URL"],
    max_connections: 5
  )

  Sequel::Model.plugin :timestamps
  Sequel::Model.plugin :dirty
  DB.extension :pg_array, :pg_json

  Rubord::Logger.info("Conectado ao banco de dados Supabase/PostgreSQL")
rescue => e
  Rubord::Logger.error("Erro ao conectar ao banco de dados: #{e.class} - #{e.message}")
end