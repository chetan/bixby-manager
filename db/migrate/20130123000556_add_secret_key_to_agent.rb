class AddSecretKeyToAgent < ActiveRecord::Migration
  def up
    change_table :agents do |t|
      t.char    :access_key,   :null => false, :after => :public_key, :limit => 32
      t.char    :secret_key,   :null => false, :after => :access_key, :limit => 128
    end
  end
end
