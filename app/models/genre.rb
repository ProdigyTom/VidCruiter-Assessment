class Genre < ApplicationRecord
  has_many :title_genres, dependent: :destroy
  has_many :titles, through: :title_genres

  validates :name, presence: true, uniqueness: true
end
