class ParseNamesKnownForTitles < ActiveRecord::Migration[7.2]
  def up
    # Load all valid title IDs into a Set for O(1) membership checks during filtering.
    valid_title_ids = Set.new(Title.pluck(:id))

    Name.where("known_for_titles IS NOT NULL AND known_for_titles <> ''").in_batches(of: 1000) do |batch|
      updates = batch.pluck(:id, :known_for_titles).map do |id, known_for_titles|
        parsed = known_for_titles
          .split(",")
          .map(&:strip)
          .reject(&:empty?)
          .select { |title_id| valid_title_ids.include?(title_id) }
          .to_json
        [ id, parsed ]
      end

      ids = updates.map(&:first)
      case_sql = updates.map { |id, val| "WHEN #{connection.quote(id)} THEN #{connection.quote(val)}" }.join(" ")
      connection.execute("UPDATE names SET known_for_titles = CASE id #{case_sql} END WHERE id IN (#{ids.map { |id| connection.quote(id) }.join(",")})")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
