class Seed < Sequel::Model(:seeds)
  many_to_one :user
end

class User < Sequel::Model(:users)
  unrestrict_primary_key

  one_to_many :seeds

  one_to_one :farm,
    key: :id,
    primary_key: :id
end