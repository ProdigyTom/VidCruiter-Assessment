class Title < ApplicationRecord
  has_one :rating, dependent: :destroy
  has_many :principals, dependent: :destroy
  has_many :crews, dependent: :destroy

  validates :primary_title, presence: true
  validates :start_year, numericality: { only_integer: true }, allow_nil: true
end
