class DropCrewTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :crew
  end

  def down
    create_table :crew do |t|
      t.string :title_id
      t.text :directors
      t.text :writers
    end
  end
end
