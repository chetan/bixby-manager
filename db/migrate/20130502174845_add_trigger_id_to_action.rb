class AddTriggerIdToAction < ActiveRecord::Migration
  def up
    change_table(:actions) do |t|
      t.integer   :trigger_id, :null => false, :after => :id
    end
    add_foreign_key :actions, :triggers

    drop_table :trigger_actions
  end

  def down
  end
end
