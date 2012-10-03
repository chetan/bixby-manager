class AddUserPhone < ActiveRecord::Migration
  def up
    add_column "users", :phone, :string, :limit => 255
  end

  def down
    remove_column "users", :phone
  end
end
