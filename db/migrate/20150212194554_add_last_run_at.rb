class AddLastRunAt < ActiveRecord::Migration
  def change
    add_column :scheduled_commands, :last_run_at, :timestamp, :after => :run_count, :null => true, :default => nil
    add_column :scheduled_commands, :last_run_status, :integer, :after => :last_run_at, :limit => 2, :null => true, :default => nil

    remove_foreign_key :scheduled_commands, :column => :last_run_log_id
    remove_column :scheduled_commands, :last_run_log_id # remove col from previous migration

    # populate field for existing ids
    ScheduledCommand.reset_column_information
    ScheduledCommand.all.each do |sc|
      last_runs = ::CommandLog.where(:scheduled_command_id => sc.id, :run_id => sc.run_count).order(:requested_at => :desc)
      next if last_runs.blank?

      sc.last_run_at = last_runs.first.requested_at
      pass = last_runs.find_all{ |r| r.success? }.size
      sc.last_run_status = if last_runs.size == pass then
        1 # all passed
      elsif pass == 0 then
        2 # all failed
      else
        3 # some failed
      end

      sc.save
    end
  end
end
