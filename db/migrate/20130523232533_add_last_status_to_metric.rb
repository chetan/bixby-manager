class AddLastStatusToMetric < ActiveRecord::Migration
  def up
    change_table(:metrics) do |t|
      t.integer :last_status, :limit => 2, :after => :last_value
    end
  end

  def down
  end
end
