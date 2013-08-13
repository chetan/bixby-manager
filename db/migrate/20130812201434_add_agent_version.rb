class AddAgentVersion < ActiveRecord::Migration
  def up
    change_table(:agents) do |t|
      t.string :version, :after => :status, :null => true
    end

    Host.all.each do |host|
      Bixby::Inventory.new.update_version(host)
    end
  end

  def down
    change_table(:agents) do |t|
      t.remove :version
    end
  end
end
