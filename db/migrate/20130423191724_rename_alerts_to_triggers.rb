class RenameAlertsToTriggers < ActiveRecord::Migration
  def up
    drop_table :alert_histories
    drop_table :alerts

    create_table :triggers do |t|
      t.integer  :check_id, :null => true
      t.integer  :metric_id, :null => true
      t.integer  :severity, :limit => 2
      t.decimal  :threshold, :precision => 20, :scale => 2
      t.string   :status, :limit => 255
      t.string   :sign, :limit => 2
      t.timestamps
    end
    add_foreign_key :triggers, :checks
    add_foreign_key :triggers, :metrics

    create_table :trigger_histories do |t|
      t.integer       :trigger_id, :null => false
      t.integer       :user_notified_id, :null => false
      t.timestamp     :created_at
      t.integer       :check_id, :null => true
      t.integer       :metric_id, :null => true
      t.integer       :severity, :limit => 2
      t.decimal       :threshold, :precision => 20, :scale => 2
      t.string        :status, :limit => 255
      t.string        :sign, :limit => 2
      t.decimal       :value, :precision => 20, :scale => 2
    end

    add_foreign_key :trigger_histories, :triggers
    add_foreign_key :trigger_histories, :users, :column => :user_notified_id
    add_foreign_key :trigger_histories, :checks
    add_foreign_key :trigger_histories, :metrics
  end

  def down
    rename_table :trigger_histories, :alert_histories
    rename_table :triggers, :alerts
  end
end
