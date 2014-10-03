class AddScheduledCommands < ActiveRecord::Migration
  def change

    create_table :scheduled_commands do |t|
      t.integer :org_id
      t.string :agent_ids
      t.integer :command_id
      t.integer :created_by

      t.text :stdin, :null => true
      t.text :args, :null => true
      t.text :env, :null => true

      t.integer :schedule_type, :limit => 2
      t.string :schedule, :null => true
      t.timestamp :scheduled_at, :null => true

      t.integer :alert_on, :null => false, :default => 0
      t.string :alert_users, :null => true
      t.text :alert_emails, :null => true

      t.timestamps
      t.timestamp :completed_at, :null => true
      t.timestamp :deleted_at, :null => true

      t.foreign_key :orgs
      t.foreign_key :commands
      t.foreign_key :users, :column => :created_by
    end

    add_column :command_logs, :scheduled_command_id, :int, :after => :command_id, :null => true
    add_column :command_logs, :env, :text, :after => :args, :null => true

  end
end
