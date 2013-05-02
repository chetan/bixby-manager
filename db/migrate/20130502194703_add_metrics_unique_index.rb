class AddMetricsUniqueIndex < ActiveRecord::Migration
  def up
    change_table(:metrics) do |t|
      t.index([:check_id, :key, :tag_hash], :unique => true)
    end
  end

  def down
  end
end
