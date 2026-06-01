class NamesController < ApplicationController
  SAMPLE = { 
    id: "ABC123", 
    primary_name: "Matt Damon", 
    birth_year: 1970, 
    death_year: nil,
    primary_profession: "actor",
    known_for_titles: "XYZ123,ABC321,CBA123" 
  }.freeze

  # GET /names
  def index
    render json: [ SAMPLE ]
  end

  # GET /names/:id
  def show
    render json: SAMPLE
  end
end
