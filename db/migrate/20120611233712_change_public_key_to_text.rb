class ChangePublicKeyToText < ActiveRecord::Migration
  def up
    change_table :agents do |t|
      t.change :public_key, :text
    end
  end

  def down
    change_table :agents do |t|
      t.change :public_key, :string
    end
  end
end
