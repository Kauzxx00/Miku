require "async"

class EvalCommand < Rubord::CommandBase
  name "eval"

  def run(message, args)
    unless message.author.id == client.owner.id
      return message.reply(
        "> #{Icons[:no]} - <@#{message.author.id}>, este comando é apenas para **desenvolvedores**.",
      )
    end

    code = args.join(" ")
    res = eval("Async { |task| #{code} }.wait", binding, __FILE__, __LINE__)
    unless res.nil?
      res = res.wait if res.is_a? Async::Task
      message.reply("```rb\n#{res}\n```")
    end
  end
end