class AddUsersDeletedAt < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :timestamp, :after => :updated_at
  end
end
