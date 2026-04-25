class PingCommand < Rubord::CommandBase
  name "ping"
  aliases "p"

  def run(message, _args)
    latency = ((Time.now - message.timestamp) * 1000).to_i

    inicio = Time.now
    DB[:users].count
    db_latency = ((Time.now - inicio) * 1000).round

    api_latency = client&.latency&.round(2)

    message.reply(
      "### #{Icons[:alert]} › Estatísticas gerais\n" \
      "> - **#{Icons[:ping]} › Resposta:** `( #{latency}ms )`\n" \
      "> - **#{Icons[:ping]} › Gateway:** `( #{api_latency}ms )`\n" \
      "> - **#{Icons[:ping]} › Database:** `( #{db_latency}ms )`"
    )
  end
end