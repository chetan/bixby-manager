class AddTriggerActions < ActiveRecord::Migration
  def up

    create_table :actions do |t|
      t.integer   :action_type, :limit => 2, :null => false
      t.integer   :target_id, :null => false
      t.text      :args
    end

    create_table(:trigger_actions, :id => false) do |t|
      t.integer   :trigger_id, :null => false
      t.integer   :action_id, :null => false
    end

    add_foreign_key :trigger_actions, :triggers
    add_foreign_key :trigger_actions, :actions


    change_table(:trigger_histories) do |t|
      t.remove_foreign_key :column => :user_notified_id
      t.remove    :user_notified_id
      t.integer   :action_type, :limit => 2, :null => false, :after => :trigger_id
      t.integer   :action_target_id, :null => false, :after => :action_type
      t.text      :action_args, :after => :action_target_id
    end

  end

  def down
  end
end
