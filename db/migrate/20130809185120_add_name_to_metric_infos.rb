class AddNameToMetricInfos < ActiveRecord::Migration
  def up
    change_table(:metric_infos) do |t|
      t.string :name, :before => :desc, :null => true
    end
  end

  def down
    change_table(:metric_infos) do |t|
      t.remove :name
    end
  end
end
