class CastController < ApplicationController
  # GET /cast/:id
  def show
    name = Name.find(params[:id])
    filmography = Title.includes(:genres, :rating).where(
      id: name.principals.where(category: %w[actor actress]).select(:title_id)
    )
    render json: person_detail(name, filmography)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Cast member not found" }, status: :not_found
  end
end
