class AddEscalationPolicy < ActiveRecord::Migration
  def up
    create_table :on_calls, { :id => false } do |t|
      t.add_id  :id
      t.string  :name
      t.int     :rotation_period, :limit => 2
      t.int     :handoff_day, :limit => 1
      t.time    :handoff_time
      t.add_id  :current_user_id, :null => true
      t.string  :users, :null => true
      t.datetime :next_handoff, :null => true
      t.timestamps
    end
    add_fk :on_calls, :user, :current_user_id

    create_table :escalation_policies, { :id => false } do |t|
      t.add_id  :id
      t.string  :name
      t.add_id  :on_call_id, :null => true
      t.timestamps
    end
    add_fk :escalation_policies, :on_call
  end

  def down
    drop_table :escalation_policies
    drop_table :on_calls
  end
end
