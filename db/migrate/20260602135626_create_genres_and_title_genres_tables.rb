class CreateGenresAndTitleGenresTables < ActiveRecord::Migration[7.2]
  def change
    create_table :genres do |t|
      t.string :name, null: false
      t.index :name, unique: true
    end

    create_table :title_genres do |t|
      t.string :title_id, null: false
      t.integer :genre_id, null: false
      t.index [ :title_id, :genre_id ], unique: true
    end
  end
end
