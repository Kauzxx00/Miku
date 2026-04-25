class Slot < Interactions::Base
  name "farm_slot"
  authorOnly? true

  def run(interaction)
    user = User[interaction.user.id]
    slot_index = interaction.values&.first.to_i
    farm = user.farm
    slot = farm.farm_slots.sort_by(&:id)[slot_index]

    container = Rubord.Container(
      Rubord.Text("### × Fazenda de [@#{interaction.user.globalname}](https://discord.com/users/#{interaction.user.id})", "-# **› Slot #{slot_index + 1}**"),
      Rubord.Separator(divider: true, spacing: :small),
      Rubord.Text(
        "**#{Icons[:farm]} › Informações gerais:**",
        if !slot.empty?
          [
            "> - **#{Icons[:seeds]} › #{slot.seed_type.capitalize}**: [` #{slot.quantity}x `]",
            "> - **#{Icons[:time]} › Tempo para colher:** <t:#{slot.harvest_at.to_i}:R>"
          ].join("\n")
        else
          "> - **#{Icons[:seeds]} › Nada plantado**"
        end
      ),
      Rubord.Text(
        "**#{Icons[:alert]} › Estatísticas:**",
        "> - **#{Icons[:user]} › Nível:** [` #{slot.level} `]",
        "> - **#{Icons[:harvest]} › Capacidade:** [` #{slot.capacity}x `]"
      ),
      Rubord.ActionRow(
        Rubord.Button(label: "› Colher", custom_id: "harvest:#{interaction.user.id}:#{slot_index}", style: 3, disabled: !slot.ready?),
        Rubord.Button(label: "› Limpar", custom_id: "clean:#{interaction.user.id}", style: 4, disabled: slot.empty?),
        Rubord.Button(label: "› Voltar", custom_id: "home:#{interaction.user.id}", style: 2)
      )
    )

    interaction.update(
      components: [container],
      flags: [:components_v2]
    )
  end
end