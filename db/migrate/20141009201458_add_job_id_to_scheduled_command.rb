class AddJobIdToScheduledCommand < ActiveRecord::Migration
  def change
    add_column :scheduled_commands, :job_id, :string, :after => :scheduled_at, :null => true
    add_column :scheduled_commands, :enabled, :boolean, :after => :scheduled_at, :null => false, :default => true
  end
end
