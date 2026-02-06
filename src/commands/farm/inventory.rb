class InventoryCommand < Rubord::CommandBase
  name "inventory"
  aliases "inv"

  def run(message, _args)
    discord_id = message.author.id.to_s
    user = User[discord_id] || User.create(id: discord_id)

    components = []

    if user.seeds.any?
      components << Rubord.Text(
        "- **Sementes**",
        user.seeds.find_all { |s| s.quantity > 0 }.map { |s|
          "> #{Icons[s.seed_type.to_sym]} - #{s.seed_type}: **#{s.quantity}**"
        }.join("\n")
      )
    end

    # if user.fertilizers&.any?
    #   components << Rubord.Text(
    #     "- **Fertilizantes**",
    #     user.fertilizers.map { |f|
    #       "> #{f.fertilizer_type}: **#{f.quantity}**"
    #     }.join("\n")
    #   )
    # end

    if components.empty?
      components << Rubord.Text("> Você não possui itens no inventário.")
    end

    container = Rubord.Container(
      Rubord.Text("## #{Icons[:inv]} - Inventário"),
      Rubord.Separator(divider: true, spacing: :small),
      *components
    )

    message.reply(components: [container], flags: [:components_v2])
  rescue => e
    Rubord::Logger.error("Erro no inventory: #{e.class} - #{e.message}")
  end
end