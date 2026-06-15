class Name < ApplicationRecord
  has_many :principals, foreign_key: :name_id
  has_many :directors, foreign_key: :name_id
  has_many :writers, foreign_key: :name_id
end
