class MigrateCrewData < ActiveRecord::Migration[7.2]
  def up
    Crew.in_batches(of: 1000) do |batch|
      director_records = []
      writer_records = []

      batch.pluck(:title_id, :directors, :writers).each do |title_id, directors, writers|
        if directors.present?
          directors.split(",").each do |name_id|
            name_id = name_id.strip
            director_records << { title_id: title_id, name_id: name_id } unless name_id.empty?
          end
        end

        if writers.present?
          writers.split(",").each do |name_id|
            name_id = name_id.strip
            writer_records << { title_id: title_id, name_id: name_id } unless name_id.empty?
          end
        end
      end

      Director.insert_all(director_records) if director_records.any?
      Writer.insert_all(writer_records) if writer_records.any?
    end
  end

  def down
    Director.delete_all
    Writer.delete_all
  end
end
