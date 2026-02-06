class BuyslotCommand < Rubord::CommandBase
  name "buy_slot"

  SLOT_PRICE ||= 500

  def run(message, _args)
    discord_id = message.author.id.to_s
    user = User.find_or_create_by(_id: discord_id)

    if user.money < SLOT_PRICE
      return message.reply(
        "> #{Icons[:no]} - <@#{discord_id}>, você não tem dinheiro suficiente para comprar um slot.\n-# - Preço: **R$#{SLOT_PRICE}**."
      )
    end

    user.inc(money: -SLOT_PRICE)
    user.farm_slots << FarmSlot.new
    user.save!

    message.reply(
      "> #{Icons[:success]} - <@#{discord_id}>, você comprou um novo slot de fazenda por **R$#{SLOT_PRICE}**!"
    )
  rescue => e
    Rubord::Logger.error("Erro no buy_slot: #{e.class} - #{e.message}")
  end
end