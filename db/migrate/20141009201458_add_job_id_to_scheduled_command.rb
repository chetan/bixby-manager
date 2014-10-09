class AddJobIdToScheduledCommand < ActiveRecord::Migration
  def change
    add_column :scheduled_commands, :job_id, :string, :after => :scheduled_at, :null => true
  end
end
