class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :_id, type: String, overwrite: true
  field :money, type: Integer, default: 0
  field :daily_claimed_at, type: Time

  embeds_many :seeds
  embeds_many :fertilizers
  embeds_many :farm_slots

  index({ _id: 1 }, unique: true)

  validates :_id, presence: true
end