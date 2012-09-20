class ChangeMetadataValueToText < ActiveRecord::Migration
  def up
    change_table :metadata do |t|
      t.change :value, :text
    end
  end

  def down
    change_table :metadata do |t|
      t.change :value, :string
    end
  end
end
