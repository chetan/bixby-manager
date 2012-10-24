class AddAlertHistory < ActiveRecord::Migration
  def up
    create_table :alert_histories, { :id => false } do |t|
      t.add_id    :id
      t.add_id    :alert_id
      t.add_id    :user_notified_id
      t.timestamp :created_at
      t.add_id    :check_id
      t.add_id    :metric_id
      t.int       :severity, :limit => 2
      t.decimal   :threshold, :precision => 20, :scale => 2
      t.char      :sign, :limit => 2
      t.decimal   :value, :precision => 20, :scale => 2
    end
    add_fk :alert_histories, :alert
    add_fk :alert_histories, :user, :user_notified_id
    add_fk :alert_histories, :check
    add_fk :alert_histories, :metric
  end

  def down
    drop_table :alert_histories
  end
end
