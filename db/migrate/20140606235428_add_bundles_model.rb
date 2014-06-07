class AddBundlesModel < ActiveRecord::Migration

  class Bundle < ActiveRecord::Base
  end

  class Command < ActiveRecord::Base
  end

  def change
    create_table :bundles do |t|
      t.integer :repo_id
      t.string :path, :length => 255
      t.string :name, :length => 255
      t.text :desc
      t.string :version, :length => 255
      t.string :digest, :length => 255
      t.timestamps
      t.timestamp :deleted_at

      t.foreign_key :repos
    end

    add_column "commands", :bundle_id, :integer, :null => true, :after => :repo_id
    add_foreign_key(:commands, :bundles)

    # populate bundles table from commands
    Bundle.reset_column_information
    Command.reset_column_information
    Command.select(:repo_id, :bundle).distinct.each do |c|
      b = Bundle.new(:repo_id => c.repo_id, :path => c.bundle)
      b.save
      Command.where(:bundle => c.bundle).each do |co|
        co.bundle_id = b.id
        co.save
      end
    end

    # cleanup
    remove_column "commands", :bundle

    # rescan repos to get all bundle details
    ::Bundle.reset_column_information
    ::Command.reset_column_information
    Bixby::Repository.new.update

    # bundle_id should be set everywhere now, change it back to not-null
    change_column "commands", :bundle_id, :integer, :null => false
  end
end
