class AddRepoUpdateJob < ActiveRecord::Migration
  def up
    job = RecurringJob.create(1.hour, Bixby::Repository, :update)
    Bixby::Scheduler.new.schedule_in(1.hour, job)
  end

  def down
  end
end
