class PrincipalsController < ApplicationController
  # GET /principals/:id
  def show
    name = Name.find(params[:id])
    principals = name.principals.includes(title: [ :genres, :rating ])

    filmography = principals.group_by(&:title_id).map do |_, credits|
      title = credits.first.title
      title_summary(title).merge(credits: credits.map { |c| credit_entry(c) })
    end

    known_for_ids = JSON.parse(name.known_for_titles || "[]")
    known_for = Title.includes(:genres, :rating).where(id: known_for_ids)

    render json: {
      id: name.id,
      name: name.primary_name,
      birth_year: name.birth_year,
      death_year: name.death_year,
      primary_professions: JSON.parse(name.primary_profession || "[]"),
      known_for: known_for.map { |t| title_summary(t) },
      filmography: filmography
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Principal not found" }, status: :not_found
  end

  private

  def credit_entry(principal)
    {
      category: principal.category,
      job: principal.job,
      role: principal.characters.present? ? JSON.parse(principal.characters) : nil
    }
  end
end
