class AddUserToCommandLog < ActiveRecord::Migration
  def change
    add_column :command_logs, :user_id, :int, :after => :org_id, :null => true
  end
end
