class ShopComamnd < Rubord::CommandBase
  name "shop"

  SEED_PRICES ||= {
    "beterraba" => 50,
    "batata" => 75,
    "trigo" => 100
  }.freeze

  FERTILIZER_PRICES ||= {
    "adubo_simples" => 150,
    "adubo_avancado" => 300
  }.freeze

  def run(message, _args)
    seed_lines = SEED_PRICES.map do |type, price|
      "> #{Icons[type.to_sym]} - **#{type.capitalize}**: R$#{price}"
    end

    fertilizer_lines = FERTILIZER_PRICES.map do |type, price|
      "> 🧴 - **#{type.split('_').map(&:capitalize).join(' ')}**: R$#{price}"
    end

    seeds_menu = Rubord.SelectMenu(
      custom_id: "shop_select_seeds",
      placeholder: "Selecione um item para comprar",
    )

    SEED_PRICES.each_key do |type|
      seeds_menu.add_option(
        label: type.capitalize,
        value: "seed_#{type}",
        description: "Comprar semente de #{type} por R$#{SEED_PRICES[type]}"
      )
    end

    fertilizer_menu = Rubord.SelectMenu(
      custom_id: "shop_select_fertilizers",
      placeholder: "Selecione um fertilizante para comprar",
    )

    FERTILIZER_PRICES.each_key do |type|
      fertilizer_menu.add_option(
        label: type.split('_').map(&:capitalize).join(' '),
        value: "fertilizer_#{type}",
        description: "Comprar #{type.split('_').map(&:capitalize).join(' ')} por R$#{FERTILIZER_PRICES[type]}",
        emoji: { name: "🧴" }
      )
    end

    container = Rubord.Container(
      Rubord.Text("## 🛒 - Loja Local"),
      Rubord.Separator(divider: true, spacing: :small),

      Rubord.Text("- **Sementes Disponíveis**", seed_lines.join("\n")),
      Rubord.ActionRow(seeds_menu),
      Rubord.Separator(spacing: :small),

      Rubord.Text("- **Fertilizantes Disponíveis**", fertilizer_lines.join("\n")),
      Rubord.ActionRow(fertilizer_menu),
    )

    message.reply(components: [container], flags: [:components_v2])
  rescue => e
    Rubord::Logger.error("Erro no shop: #{e.class} - #{e.full_message}")
  end
end