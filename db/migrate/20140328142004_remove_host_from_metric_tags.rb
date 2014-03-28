class RemoveHostFromMetricTags < ActiveRecord::Migration

  class ::Metric < ActiveRecord::Base
    def update_tag_hash(metadata)
      self.tag_hash = self.class.hash_metadata(metadata)
    end
  end

  def up
    # remove "host" key for each metric
    Metric.all.each do |m|
      m.tags.where(:key => "host").destroy_all
    end

    # then go through and fix all the hashes
    Metric.all.each do |m|
      tags = {}
      m.tags.each{ |t| tags[t.key] = t.value }
      m.update_tag_hash(tags)
      m.save!
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration.new("can't reverse this")
  end

end
