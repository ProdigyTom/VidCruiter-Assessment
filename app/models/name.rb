class Name < ApplicationRecord
  has_many :principals, foreign_key: :name_id
end
