class RatingsController < ApplicationController
  SAMPLE = { 
    id: 1, 
    title_id: "ABC123", 
    average_rating: 6.5, 
    number_of_votes: 194 
  }.freeze

  # GET /ratings
  def index
    render json: [ SAMPLE ]
  end

  # GET /ratings/:id
  def show
    render json: SAMPLE
  end
end
