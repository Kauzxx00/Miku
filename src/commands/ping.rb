class PingCommand < Rubord::CommandBase
  name "ping"

  def run(message, args)
    message.post("testee")
  end
end