class AddCommandLogs < ActiveRecord::Migration
  def change

    create_table :command_logs do |t|
      t.integer :org_id
      t.integer :agent_id
      t.integer :command_id
      t.text :stdin, :null => true
      t.text :args, :null => true
      t.boolean :exec_status
      t.integer :exec_code
      t.integer :status, :null => true
      t.text :stdout, :null => true
      t.text :stderr, :null => true
      t.timestamp :requested_at
      t.decimal :time_taken, :precision => 10, :scale => 3

      t.foreign_key :orgs
      t.foreign_key :agents
      t.foreign_key :commands
    end

  end
end
