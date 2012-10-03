class AddUserPw < ActiveRecord::Migration
  def up
    add_column "users", :password, :string, :limit => 255, :after => :username
  end

  def down
    remove_column "users", :password
  end
end
