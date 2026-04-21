class MainFarm < Interactions::Base
  name "home"
  authorOnly? true

  SLOTS_PER_TERRAIN = 16

  def run(interaction)
    discord_id = interaction.user.id.to_s
    page = 1

    user = User[discord_id]
    farm = user.farm

    slots = farm.farm_slots_dataset.order(:id).all

    total_pages = [(slots.size.to_f / SLOTS_PER_TERRAIN).ceil, 1].max
    page = total_pages if page > total_pages

    start = (page - 1) * SLOTS_PER_TERRAIN
    page_slots = slots.slice(start, SLOTS_PER_TERRAIN) || []
    page_slots += [nil] * (SLOTS_PER_TERRAIN - page_slots.size)

    renderer = Rubord::UI::FarmRenderer.new(
      page_slots,
      user_id: discord_id
    )
    
    btn = Rubord.ActionRow(
      Rubord.Button(label: "› Colher tudo", custom_id: "harvest_all:#{discord_id}", style: 3, disabled: !slots.map{ |s| s.status }.include?("ready"))
    )

    navigation =
      if total_pages > 1
        Rubord.Text(
          "-# 🌍 Terreno #{page}/#{total_pages}",
          "-# m.farm #{page - 1} • m.farm #{page + 1}"
        )
      end

    container = Rubord.Container(
      Rubord.Text("### × Fazenda de [@#{interaction.user.globalname}](https://discord.com/users/#{interaction.user.id})"),
      Rubord.Separator(divider: true, spacing: :small),
      Rubord.Text("- **#{Icons[:farm]} › Terreno: 1**", renderer.grid),
      *renderer.slot_menu,
      btn,
      Rubord.Separator(spacing: :small),
      navigation
    )
    
    interaction.update(
      components: [container],
      flags: [:components_v2]
    )
  end
end