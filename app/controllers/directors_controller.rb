class DirectorsController < ApplicationController
  # GET /directors/:id
  def show
    name = Name.find(params[:id])
    filmography = Title.includes(:genres, :rating).where(id: name.directors.select(:title_id))
    render json: person_detail(name, filmography)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Director not found" }, status: :not_found
  end
end
