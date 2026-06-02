class ParseNamesPrimaryProfession < ActiveRecord::Migration[7.2]
  def up
    Name.where("primary_profession IS NOT NULL AND primary_profession <> ''").in_batches(of: 1000) do |batch|
      updates = batch.pluck(:id, :primary_profession).map do |id, primary_profession|
        parsed = primary_profession.split(",").map(&:strip).reject(&:empty?).to_json
        [ id, parsed ]
      end

      ids = updates.map(&:first)
      case_sql = updates.map { |id, val| "WHEN #{connection.quote(id)} THEN #{connection.quote(val)}" }.join(" ")
      connection.execute("UPDATE names SET primary_profession = CASE id #{case_sql} END WHERE id IN (#{ids.map { |id| connection.quote(id) }.join(",")})")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
