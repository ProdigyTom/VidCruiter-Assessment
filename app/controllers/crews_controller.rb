class CrewsController < ApplicationController
  SAMPLE = { 
    id: 1, 
    title_id: "ABC123", 
    directors: "Ron Howard",
    writers: "John Smith,Jane Doe" 
  }.freeze

  # GET /crews
  def index
    render json: [ SAMPLE ]
  end

  # GET /crews/:id
  def show
    render json: SAMPLE
  end
end
