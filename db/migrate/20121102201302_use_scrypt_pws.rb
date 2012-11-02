class UseScryptPws < ActiveRecord::Migration
  def up
    remove_columns :tenants, :password
    change_table :tenants do |t|
      t.char :password, :limit => 89, :after => :name
    end

    remove_columns :users, :password
    change_table :users do |t|
      t.char :password, :limit => 89, :after => :username
    end
  end

  def down
  end
end
