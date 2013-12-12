class AddAgentLastSeen < ActiveRecord::Migration
  def up
    change_table(:agents) do |t|
      t.timestamp :last_seen_at, :null => true, :default => nil
      t.boolean :is_connected, :default => false
    end
  end

  def down
    change_table(:agents) do |t|
      t.remove :last_seen_at
      t.remove :is_connected
    end
  end
end
