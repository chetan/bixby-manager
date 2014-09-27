class AddScheduledCommands < ActiveRecord::Migration
  def change

    create_table :scheduled_commands do |t|
      t.integer :org_id
      t.integer :agent_id
      t.integer :command_id
      t.integer :created_by

      t.text :stdin, :null => true
      t.text :args, :null => true

      t.integer :schedule_type, :limit => 2
      t.string :schedule, :null => true
      t.timestamp :scheduled_at, :null => true

      t.integer :command_log_id
      t.timestamp :completed_at

      t.foreign_key :orgs
      t.foreign_key :agents
      t.foreign_key :commands
      t.foreign_key :users, :column => :created_by
    end

    add_column :command_logs, :scheduled_command_id, :int, :after => :command_id, :null => true

  end
end
