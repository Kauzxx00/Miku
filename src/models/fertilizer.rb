class Fertilizer
  include Mongoid::Document
  embedded_in :user

  field :fertilizer_type, type: String
  field :effect, type: String
  field :value, type: Integer
  field :quantity, type: Integer, default: 0

  validates :fertilizer_type, :effect, presence: true
end