class RenamePwField < ActiveRecord::Migration
  def up
    # meh authlogic!
    rename_column :users, :password, :crypted_password
  end

  def down
    rename_column :users, :crypted_password, :password
  end
end
