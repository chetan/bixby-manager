class AddSoftDeleteCols < ActiveRecord::Migration
  def up
    add_column "agents", :deleted_at, :timestamp
    add_column "hosts", :deleted_at, :timestamp
  end

  def down
    remove_column "agents", :deleted_at
    remove_column "hosts", :deleted_at
  end
end
