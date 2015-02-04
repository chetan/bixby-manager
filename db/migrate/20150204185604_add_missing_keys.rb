class AddMissingKeys < ActiveRecord::Migration
  def change
    add_foreign_key "command_logs", "scheduled_commands", name: "command_logs_scheduled_command_id_fk"
    add_foreign_key "command_logs", "users", name: "command_logs_user_id_fk"
  end
end
