class FlattenMetadata < ActiveRecord::Migration

  class Metadata < ActiveRecord::Base
  end

  class Host < ActiveRecord::Base
    has_and_belongs_to_many :metadata, :class_name => :Metadata, :join_table => "hosts_metadata"
  end

  class Metric < ActiveRecord::Base
    has_and_belongs_to_many :tags, :class_name => :Metadata, :join_table => "metrics_metadata"
  end

  def up

    # add new cols to metadata
    change_table :metadata do |t|
      t.integer   :object_type, :null => true, :after => :id, :limit => 2 # small int
      t.integer   :object_id  , :null => true, :after => :object_type
    end
    Metadata.reset_column_information

    # Migrate all host metadata
    Host.all.each do |host|
      host.metadata.each do |m|
        md             = Metadata.new
        md.key         = m.key
        md.value       = m.value
        md.source      = m.source
        md.object_type = 1 # host type
        md.object_id   = host.id
        md.save
      end
    end

    # Migrate metric tags
    Metric.all.each do |metric|
      metric.tags.each do |m|
        md             = Metadata.new
        md.key         = m.key
        md.value       = m.value
        md.source      = m.source
        md.object_type = 2 # metric type
        md.object_id   = metric.id
        md.save
      end
    end

    # drop join tables
    drop_table :hosts_metadata
    drop_table :metrics_metadata

    # cleanup metadata
    Metric.connection.execute("DELETE FROM metadata WHERE object_type IS NULL")
  end

  def down
  end
end
