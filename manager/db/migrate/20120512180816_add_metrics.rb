class AddMetrics < ActiveRecord::Migration
  def up
    create_table :metrics, { :id => false } do |t|
      t.add_id :id
      t.add_id :resource_id
      t.add_id :check_id
      t.string "key", :limit => 255
      t.integer "status", :limit => 2
      t.decimal "last_value", :precision => 20, :scale => 2
      t.timestamps
    end

    add_fk :metrics, :resource
    add_fk :metrics, :check
  end

  def down
    drop_table :metrics
  end
end
