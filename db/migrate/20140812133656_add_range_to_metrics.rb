class AddRangeToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :range, :string, :length => 255, :after => :key
    Metric.reset_column_information
    Bixby::Monitoring.new.update_metric_ranges
  end
end
