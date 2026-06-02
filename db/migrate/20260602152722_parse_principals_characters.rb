class ParsePrincipalsCharacters < ActiveRecord::Migration[7.2]
  def up
    Principal.where("characters IS NOT NULL AND characters <> ''").in_batches(of: 1000) do |batch|
      updates = batch.pluck(:id, :characters).map do |id, characters|
        content = characters.strip
        content = content[1..-2] if content.start_with?("[") && content.end_with?("]")
        parsed = content.split(",").map(&:strip).reject(&:empty?).to_json
        [ id, parsed ]
      end

      ids = updates.map(&:first)
      case_sql = updates.map { |id, val| "WHEN #{id} THEN #{connection.quote(val)}" }.join(" ")
      connection.execute("UPDATE principals SET characters = CASE id #{case_sql} END WHERE id IN (#{ids.join(",")})")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
