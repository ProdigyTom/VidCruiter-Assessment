class Title < ApplicationRecord
  has_one :rating, dependent: :destroy
  has_many :principals, dependent: :destroy
  has_many :title_genres, dependent: :destroy
  has_many :genres, through: :title_genres
  has_many :directors, dependent: :destroy
  has_many :writers, dependent: :destroy

  validates :primary_title, presence: true
  validates :start_year, numericality: { only_integer: true }, allow_nil: true
end
