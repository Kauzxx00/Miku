class DailyCommand < Rubord::CommandBase
  name "daily"

  def run(message, args)
    user = User.create
  end
end