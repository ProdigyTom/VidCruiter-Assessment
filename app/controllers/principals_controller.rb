class PrincipalsController < ApplicationController
  SAMPLE = { 
    id: 1, 
    title_id: "ABC123", 
    ordering: 1, 
    name_id: "XYZ789",
    category: "actor", 
    job: nil, 
    characters: "[Vito Corleone, Michael Corleone, Sonny Corleone]" 
  }.freeze

  # GET /principals
  def index
    render json: [ SAMPLE ]
  end

  # GET /principals/:id
  def show
    render json: SAMPLE
  end
end
