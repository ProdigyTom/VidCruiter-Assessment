class CreateWritersTable < ActiveRecord::Migration[7.2]
  def change
    create_table :writers do |t|
      t.string :title_id, null: false
      t.string :name_id, null: false
      t.index [ :title_id, :name_id ], unique: true
    end
  end
end
