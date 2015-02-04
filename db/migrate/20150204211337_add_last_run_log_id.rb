class AddLastRunLogId < ActiveRecord::Migration
  def change
    add_column :scheduled_commands, :last_run_log_id, :integer, :after => :run_count, :default => :null
    add_foreign_key :scheduled_commands, :command_logs, :column => :last_run_log_id

    # populate field for existing ids
    ScheduledCommand.reset_column_information
    ScheduledCommand.all.each do |sc|
      last_run = ::CommandLog.where(:scheduled_command_id => sc.id, :run_id => sc.run_count).order(:requested_at => :desc).first
      next if last_run.nil?

      sc.last_run_log_id = last_run.id
      sc.save
    end

  end
end
