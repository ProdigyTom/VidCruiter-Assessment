class MigrateTitlesGenres < ActiveRecord::Migration[7.2]
  def up
    # Collect every distinct genre name across all titles in one pass
    genre_names = Set.new
    Title.where("genres IS NOT NULL AND genres <> ''").pluck(:genres).each do |genres_str|
      genres_str.split(",").each { |g| genre_names << g.strip }
    end

    Genre.insert_all(genre_names.map { |name| { name: name } })

    genres_map = Genre.pluck(:name, :id).to_h

    # Batch through titles building join records, then bulk insert each batch
    Title.where("genres IS NOT NULL AND genres <> ''").in_batches(of: 1000) do |batch|
      records = batch.pluck(:id, :genres).flat_map do |title_id, genres_str|
        genres_str.split(",").filter_map do |genre_name|
          genre_id = genres_map[genre_name.strip]
          { title_id: title_id, genre_id: genre_id } if genre_id
        end
      end

      TitleGenre.insert_all(records) if records.any?
    end
  end

  def down
    TitleGenre.delete_all
    Genre.delete_all
  end
end
