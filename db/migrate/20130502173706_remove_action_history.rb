class RemoveActionHistory < ActiveRecord::Migration
  def up
    change_table(:trigger_histories) do |t|
      t.remove :action_type
      t.remove :action_target_id
      t.remove :action_args
    end
  end

  def down
  end
end
