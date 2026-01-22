require_relative "../client.rb"

# @param client [Rubord::Client]
def harvest_notifications(client)
  User.all.each do |user|
    user.farm_slots.each do |slot|
      next unless slot.harvest_at
      next if slot.ready?

      delay = slot.harvest_at - Time.now
      next if delay <= 0

      Async do
        sleep(delay)

        begin
          updated_user = User.find(user.id)
          updated_slot = updated_user.farm_slots.find { |f| f.id == slot.id }

          next unless updated_slot&.ready?

          channel = client.fetch_channel(slot.channel_id.to_i).wait
          next unless channel

          channel.post(
            "> 🌾 - <@#{user.id}>, sua plantação de **#{updated_slot.seed_type}** está pronta para colheita!"
          )
        rescue => e
          Rubord::Logger.error(
            "Erro ao notificar colheita para #{user.id}: #{e.class} - #{e.message}"
          )
        end
      end
    end
  end
end
