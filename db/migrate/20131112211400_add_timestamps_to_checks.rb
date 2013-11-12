class AddTimestampsToChecks < ActiveRecord::Migration
  def up
    add_column "checks", :created_at, :timestamp
    add_column "checks", :updated_at, :timestamp
    add_column "checks", :deleted_at, :timestamp
  end

  def down
    remove_column "checks", :created_at
    remove_column "checks", :updated_at
    remove_column "checks", :deleted_at
  end
end
