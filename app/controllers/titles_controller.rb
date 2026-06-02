class TitlesController < ApplicationController
  before_action :set_title, only: [ :show, :writers, :directors, :cast, :principals ]

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
  end

  # GET /titles/:id/writers
  def writers
  end

  # GET /titles/:id/directors
  def directors
  end

  # GET /titles/:id/cast
  def cast
  end

  # GET /titles/:id/principals
  def principals
  end

  private

  def set_title
    @title = Title.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Title not found" }, status: :not_found
  end

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
end
