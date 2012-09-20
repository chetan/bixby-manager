class AddMetrics < ActiveRecord::Migration
  def up
    create_table :metrics, { :id => false } do |t|
      t.add_id :id
      t.add_id :resource_id
      t.add_id :check_id
      t.string "key", :limit => 255, :null => false
      t.char "tag_hash", :limit => 32, :null => false
      t.integer "status", :limit => 2
      t.decimal "last_value", :precision => 20, :scale => 2
      t.timestamps
    end

    add_fk :metrics, :resource
    add_fk :metrics, :check

    create_table :tags, { :id => false } do |t|
      t.add_id :id
      t.string "key", :limit => 255
      t.string "value", :limit => 255
    end

    create_table :metrics_tags, { :id => false } do |t|
      t.add_id :metric_id
      t.add_id :tag_id
    end

    add_fk :metrics_tags, :metric
    add_fk :metrics_tags, :tag

  end

  def down
    drop_table :metrics_tags
    drop_table :metrics
    drop_table :tags
  end
end
