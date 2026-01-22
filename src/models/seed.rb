class Seed
  include Mongoid::Document
  embedded_in :user

  field :seed_type, type: String
  field :quantity, type: Integer, default: 0

  validates :seed_type, presence: true
end