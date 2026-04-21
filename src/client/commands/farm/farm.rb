module Rubord
  module UI
    class FarmRenderer
      DEFAULT_COLS ||= 4

      EMOJIS ||= {
        locked: Icons[:locked],
        empty: Icons[:dirt],
        growing: {
          batata: Icons[:batata],
          beterraba: Icons[:beterraba]
        },
        ready: {
          beterraba: Icons[:ready_beterraba],
          batata: Icons[:ready_batata]
        },
        dead: "💀"
      }

      STATUS_LABEL ||= {
        empty: "Vazio",
        growing: "Crescendo",
        ready: "Pronto",
        dead: "Morto"
      }

      def initialize(slots, user_id:, cols: DEFAULT_COLS)
        @slots = slots
        @cols = cols
        @user_id = user_id
      end

      def grid
        emojis = @slots.map { |s| emoji_for(s) }

        emojis
          .each_slice(@cols)
          .map { |row| "> " + row.join("") }
          .join("\n")
      end

      def slot_menu
        menu = Rubord.SelectMenu(
          custom_id: "farm_slot:#{@user_id}",
          placeholder: ": Escolha um slot...",
          min_values: 1,
          max_values: 1
        )

        @slots.each_with_index do |slot, index|
          next if slot.nil?
          status = status_of(slot)

          menu.add_option(
            label: "› Slot: #{index + 1}",
            value: index.to_s,
            description: "#{status == :ready ? "•" : "×"} #{"#{slot.seed_type.capitalize} ( " if status != :empty}#{STATUS_LABEL[status]}#{" )" if status != :empty}"
          )
        end

        Rubord.ActionRow(menu)
      end

      private

      def emoji_for(slot)
        return EMOJIS[:locked] if slot.nil?

        status = status_of(slot)
        type = slot.seed_type&.to_sym

        case EMOJIS[status]
        when Hash
          EMOJIS[status][type] || EMOJIS[:empty]
        else
          EMOJIS[status]
        end
      end

      def status_of(slot)
        case slot.status
        when "ready" then :ready
        when "dead" then :dead
        when "empty" then :empty
        else :growing
        end
      end
    end
  end
end

class FarmCommand < Rubord::CommandBase
  name "farm"
  aliases "fazenda"

  SLOTS_PER_TERRAIN ||= 16

  def run(message, args)
    discord_id = message.author.id.to_s
    page = [(args[0] || 1).to_i, 1].max

    user = User[discord_id] || User.create(id: discord_id)
    farm = user.farm || create_farm_for(user)

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
      Rubord.Text("### × Fazenda de [@#{message.author.globalname}](https://discord.com/users/#{message.author.id})"),
      Rubord.Separator(divider: true, spacing: :small),
      Rubord.Text("- **#{Icons[:farm]} › Terreno: 1**", renderer.grid),
      *renderer.slot_menu,
      btn,
      Rubord.Separator(spacing: :small),
      navigation
    )
    
    message.reply(
      components: [container],
      flags: [:components_v2]
    )
  end

  private

  def create_farm_for(user)
    farm = Farm.create(id: user.id)

    4.times do
      FarmSlot.create(farm_id: farm.id)
    end

    farm
  end
end