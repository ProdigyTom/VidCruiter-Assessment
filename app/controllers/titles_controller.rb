class TitlesController < ApplicationController
  SAMPLE = { 
    id: "ABC123", 
    primary_title: "The Godfather", 
    original_title: "The Godfather",
    start_year: 1972, 
    runtime: 175, 
    genres: "Action,Crime" 
  }.freeze

  # GET /titles
  def index
    render json: [ SAMPLE ]
  end

  # GET /titles/:id
  def show
    render json: SAMPLE
  end
end
