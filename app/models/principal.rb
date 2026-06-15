class Principal < ApplicationRecord
  belongs_to :title
  belongs_to :name, foreign_key: :name_id
end
