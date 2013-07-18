class AddDescAndLocationToCommands < ActiveRecord::Migration
  def up
    change_table(:commands) do |t|
      t.string :desc, :after => :name, :null => true
      t.string :location, :after => :desc, :null => true
    end
  end

  def down
    change_table(:commands) do |t|
      t.remove :desc, :location
    end
  end
end
