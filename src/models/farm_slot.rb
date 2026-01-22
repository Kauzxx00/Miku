class FarmSlot
  include Mongoid::Document
  embedded_in :user

  field :level, type: Integer, default: 1
  field :capacity, type: Integer, default: 5

  field :seed_type, type: String
  field :quantity, type: Integer, default: 0

  field :planted_at, type: Time
  field :harvest_at, type: Time

  field :fertilizer_type, type: String
  field :channel_id, type: String

  validates :level, numericality: { greater_than: 0 }

  def empty?
    planted_at.nil?
  end

  def growing?
    planted_at && !ready? && !dead?
  end

  def ready?
    harvest_at && Time.now >= harvest_at
  end

  def dead?
    harvest_at && Time.now > (harvest_at + grace_time)
  end

  def plant!(seed_type:, quantity:, duration:)
    self.seed_type  = seed_type
    self.quantity   = quantity
    self.planted_at = Time.now
    self.harvest_at = planted_at + duration
  end

  def apply_fertilizer!(fertilizer)
    self.fertilizer_type = fertilizer.fertilizer_type

    case fertilizer.effect.to_sym
    when :reduce_time
      self.harvest_at -= fertilizer.value
    when :weather_resist
      # efeito pode ser calculado externamente (clima)
    end
  end

  def clear!
    self.attributes = {
      seed_type: nil,
      quantity: 0,
      planted_at: nil,
      harvest_at: nil,
      fertilizer_type: nil
    }
  end

  private

  def grace_time
    0.2 * (harvest_at - planted_at)
  end
end