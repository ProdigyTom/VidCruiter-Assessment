class ApplicationController < ActionController::API
  private

  def title_summary(title)
    {
      id: title.id,
      title: title.primary_title,
      year: title.start_year,
      runtime: title.runtime,
      genres: title.genres.map(&:name),
      rating: title.rating&.average_rating
    }
  end

  def name_summary(name)
    { id: name.id, name: name.primary_name }
  end

  def principal_entry(principal)
    {
      id: principal.name.id,
      name: principal.name.primary_name,
      role: principal.characters.present? ? JSON.parse(principal.characters) : []
    }
  end

  def person_detail(name, filmography_titles)
    known_for_ids = JSON.parse(name.known_for_titles || "[]")
    known_for = Title.includes(:genres, :rating).where(id: known_for_ids)

    {
      id: name.id,
      name: name.primary_name,
      birth_year: name.birth_year,
      death_year: name.death_year,
      primary_professions: JSON.parse(name.primary_profession || "[]"),
      known_for: known_for.map { |t| title_summary(t) },
      filmography: filmography_titles.map { |t| title_summary(t) }
    }
  end
end
