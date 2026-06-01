class Rating < ApplicationRecord
  belongs_to :title

  validates :average_rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :number_of_votes, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
