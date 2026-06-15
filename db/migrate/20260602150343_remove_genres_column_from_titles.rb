class RemoveGenresColumnFromTitles < ActiveRecord::Migration[7.2]
  def up
    remove_column :titles, :genres
  end

  def down
    add_column :titles, :genres, :string
  end
end
