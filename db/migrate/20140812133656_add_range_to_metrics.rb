class AddRangeToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :range, :string, :length => 255, :after => :key
  end
end
