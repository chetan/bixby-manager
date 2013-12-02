class AddRangePlatformsToMetricInfos < ActiveRecord::Migration
  def up
    change_table(:metric_infos) do |t|
      t.string :range, :null => true, :limit => 255
      t.string :platforms, :null => true, :limit => 255
    end

    # touch all commands to force a rescan update
    Command.all.each do |c|
      filename = c.to_command_spec.command_file
      FileUtils.touch(filename) if File.exists? filename
    end
  end

  def down
    change_table(:metric_infos) do |t|
      t.remove :range
      t.remove :platforms
    end
  end
end
