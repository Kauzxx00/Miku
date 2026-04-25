class HelpCommand < Rubord::CommandBase
  name "help"
  aliases "ajuda", "comandos"

  def run(message, _args)
    container = Rubord.Container(
      Rubord.Text("### × Lista de comandos"),
      Rubord.Separator(divider: true, spacing: :small),
      Rubord.Text("**#{Icons[:farm]} - Fazenda:**",
        "> - `plantar` - **Plante uma semente na sua fazenda.**",
        "> - `colher` - **Colha as plantas maduras da sua fazenda.**",
        "> - `fazenda` - **Veja o status da sua fazenda.**",
        "> - `inventario` - **Veja seu inventário.**",
        "> - `perfil` - **Veja seu perfil.**",
        "> - `buy_slot` - **Compre um novo slot para sua fazenda.**"
      ),
      Rubord.Text("**#{Icons[:ping]} - Utilitários:**",
        "> - `daily` - **Reivindique sua recompensa diária.**",
        "> - `botinfo` - **Veja todas as minhas informações.**",
        "> - `help` - **Veja esta mensagem de ajuda.**",
        "> - `ping` - **Veja a minha latência.**"
      )
    )

    message.reply(
      components: [container],
      flags: [:components_v2]
    )
  end
end