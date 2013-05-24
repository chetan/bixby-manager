class AddSoftDeleteForTriggers < ActiveRecord::Migration
  def up
    add_column "triggers", :deleted_at, :timestamp
    add_column "actions", :deleted_at, :timestamp
  end

  def down
    remove_column "triggers", :deleted_at
    remove_column "actions", :deleted_at
  end
end
