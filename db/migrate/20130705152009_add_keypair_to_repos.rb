class AddKeypairToRepos < ActiveRecord::Migration
  def up
    change_table(:repos) do |t|
      t.text :private_key, :after => :branch, :null => true
      t.text :public_key, :after => :private_key, :null => true
    end
  end

  def down
    change_table(:repos) do |t|
      t.remove :private_key, :public_key
    end
  end
end
