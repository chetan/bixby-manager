class AddCommandSoftDelete < ActiveRecord::Migration
  def up
    add_column "commands", :deleted_at, :timestamp
  end
  def down
    remove_column "commands", :deleted_at
  end
end
