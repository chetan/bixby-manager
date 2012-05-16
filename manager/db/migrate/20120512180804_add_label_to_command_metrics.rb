class AddLabelToCommandMetrics < ActiveRecord::Migration
  def change
    add_column "command_metrics", "label", :string, :limit => 255, :default => nil, :null => true
  end
end
