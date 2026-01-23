class InventoryCommand < Rubord::CommandBase
  name "inventory"

  def run(message, args)
    container = Rubord.Container(
      Rubord.Text "Teste"
    )

    message.reply(components: [container], flags: [:components_v2])
  end
end
