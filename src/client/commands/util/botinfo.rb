class InfoCommand < Rubord::CommandBase
  name "botinfo"
  aliases "info", "stats"

  def run(message, _args)
    uptime = client.uptime

    total_users = User.count
    total_farms = Farm.count

    container = Rubord.Container(
      Rubord.Text("### × Minhas informações"),
      Rubord.Separator(divider: true, spacing: :small),
      Rubord.Text("**#{Icons[:farm]} › Informações gerais:**",
        "> - #{Icons[:harvest]} - **Meu dono:** <@#{client.application.owner.id}>",
        "> - #{Icons[:notify]} - **Prefixo atual:** #{client.prefix}",
        "> - #{Icons[:ping]} - **Servidores:** #{client.guilds.count}"
      ),
      Rubord.Text("**#{Icons[:ping]} › Estatísticas gerais:**",
        "> - #{Icons[:time]} - **Tempo online:** <t:#{uptime}:R>",
        "> - #{Icons[:user]} - **Total de usuários:** #{total_users}",
        "> - #{Icons[:farm]} - **Fazendas criadas:** #{total_farms}"
      )
    )

    message.reply(
      components: [container],
      flags: [:components_v2]
    )
  end
end