class RenameCommandMetrics < ActiveRecord::Migration
  def change
    rename_table "command_metrics", "metric_infos"
  end
end
