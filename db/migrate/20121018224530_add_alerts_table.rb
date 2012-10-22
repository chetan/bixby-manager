class AddAlertsTable < ActiveRecord::Migration
  def up
    create_table :alerts, { :id => false } do |t|
      t.add_id  :id
      t.add_id  :check_id, :null => true
      t.add_id  :metric_id, :null => true
      t.integer :severity, :limit => 2
      t.decimal :threshold, :precision => 20, :scale => 2
      t.char    :sign, :limit => 2
      t.timestamps
    end
    add_fk :alerts, :check
    add_fk :alerts, :metric
  end

  def down
    drop_table :alerts
  end
end
