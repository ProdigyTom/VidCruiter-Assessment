class TitlesController < ApplicationController
  before_action :set_title, only: [ :writers, :directors, :cast, :principals ]

  # GET /titles
  def index
    filter_keys = %i[year runtime genre rating]
    active_filters = params.slice(*filter_keys).select { |_, v| v.present? }

    if active_filters.empty?
      render json: { error: "At least one filter is required (year, runtime, genre, rating)" }, status: :bad_request
      return
    end

    titles = Title.all
    titles = titles.by_year(active_filters[:year])       if active_filters[:year]
    titles = titles.by_runtime(active_filters[:runtime]) if active_filters[:runtime]
    titles = titles.by_genre(active_filters[:genre])     if active_filters[:genre]
    titles = titles.by_rating(active_filters[:rating])   if active_filters[:rating]

    render json: titles.includes(:genres, :rating).map { |t| title_summary(t) }
  end

  # GET /titles/:id
  def show
    title = Title
      .includes(:genres, :rating, { writers: :name }, { directors: :name }, { principals: :name })
      .find(params[:id])

    cast       = title.principals.select { |p| %w[actor actress].include?(p.category) }
    principals = title.principals

    render json: {
      id: title.id,
      title: title.primary_title,
      original_title: title.original_title,
      year: title.start_year,
      runtime: title.runtime,
      genres: title.genres.map(&:name),
      rating: title.rating&.average_rating,
      writers: title.writers.map { |w| name_summary(w.name) },
      directors: title.directors.map { |d| name_summary(d.name) },
      cast: cast.map { |p| principal_entry(p) },
      principals: principals.map { |p| principal_entry(p) }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Title not found" }, status: :not_found
  end

  # GET /titles/:id/writers
  def writers
    render json: @title.writers.includes(:name).map { |w| name_summary(w.name) }
  end

  # GET /titles/:id/directors
  def directors
    render json: @title.directors.includes(:name).map { |d| name_summary(d.name) }
  end

  # GET /titles/:id/cast
  def cast
    people = @title.principals.includes(:name).where(category: %w[actor actress])
    render json: people.map { |p| principal_entry(p) }
  end

  # GET /titles/:id/principals
  def principals
    render json: @title.principals.includes(:name).map { |p| principal_entry(p) }
  end

  private

  def set_title
    @title = Title.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Title not found" }, status: :not_found
  end

end
