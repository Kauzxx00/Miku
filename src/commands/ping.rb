class PingCommand < Rubord::CommandBase
  name "ping"
  aliases "p"

  def run(message, _args)
    latency = (message.timestamp.to_i - Time.now.to_i)
    message.reply(
      "> #{Icons[:ping]} - Estatísticas gerais\n" \
      "-# - Tempo online: <t:#{client.uptime}:R>\n" \
      "-# - Tempo de resposta: **`#{latency}s`**\n" \
      "-# - Tempo de resposta da API: **`#{client&.latency&.round(2)}ms`**"
    )
  end
end