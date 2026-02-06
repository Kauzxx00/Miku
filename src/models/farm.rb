class Farm < Sequel::Model(:farms)
  unrestrict_primary_key

  one_to_many :farm_slots
  many_to_one :user, key: :id

  def full?
    farm_slots.count >= max_slots
  end

  def empty_slot
    farm_slots.find(&:empty?)
  end
end

class FarmSlot < Sequel::Model(:farm_slots)
  many_to_one :farm

  def empty?
    planted_at.nil?
  end

  def ready?
    harvest_at && Time.now >= harvest_at
  end

  def dead?
    harvest_at && Time.now > harvest_at + grace_time
  end

  def growing?
    planted_at && !ready? && !dead?
  end

  def status
    return "empty" if empty?
    return "ready" if ready?
    return "dead" if dead?
    "growing"
  end

  def plant!(seed_type:, quantity:, duration:, channel_id:)
    update(
      seed_type: seed_type,
      quantity: quantity,
      planted_at: Time.now,
      harvest_at: Time.now + duration,
      channel_id: channel_id
    )
  end

  def clear!
    update(
      seed_type: nil,
      quantity: 0,
      planted_at: nil,
      harvest_at: nil,
      fertilizer_type: nil
    )
  end

  private

  def grace_time
    0.2 * (harvest_at - planted_at)
  end
end