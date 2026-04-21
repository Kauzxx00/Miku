class EvalCommand < Rubord::CommandBase
  name "eval"

  def run(message, args)
    unless message.author.id == client.application.owner.id
      return message.reply(
        "> #{Icons[:no]} - <@#{message.author.id}>, este comando é apenas para **desenvolvedores**.",
      )
    end

    code = message.content.split(" ", 2)[1]
    begin
      result = eval(code)
      message.reply("```rb\n#{result.inspect}\n```")
    rescue StandardError => e
      pp (e.message)
    end
  end
end