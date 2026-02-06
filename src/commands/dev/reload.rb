class ReloadCommand < Rubord::CommandBase
  name "reload"
  aliases "r"

  def run(message, args)
    unless message.author.id == client.application.owner.id
      return message.reply(
        "> #{Icons[:no]} - <@#{message.author.id}>, este comando é apenas para **desenvolvedores**.",
      )
    end

    begin
      Rubord::CommandLoader.load("./src/commands", client, client.commands)
      message.reply("> #{Icons[:yes]} - Sucesso ao **atualizar** todos os **comandos**!")
    rescue StandardError => e
      pp e
      message.reply("> #{Icons[:no]} - Erro ao **atualizar** comandos.")
    end
  end
end