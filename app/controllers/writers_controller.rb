class WritersController < ApplicationController
  # GET /writers/:id
  def show
    name = Name.find(params[:id])
    filmography = Title.includes(:genres, :rating).where(id: name.writers.select(:title_id))
    render json: person_detail(name, filmography)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Writer not found" }, status: :not_found
  end
end
