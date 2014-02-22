class SortAllMetricHashes < ActiveRecord::Migration

  class ::Metric < ActiveRecord::Base
    def update_tag_hash(metadata)
      self.tag_hash = self.class.hash_metadata(metadata)
    end
  end

  # since we're now sorting all tags (see e468e7f and 6416df4), we need to
  # update all existing metrics so we don't store them twice
  def up
    ActiveRecord::Base.transaction do

      # first go through and delete and duplicates, based on the check_id/key/created_at
      del = []
      metrics = Metric.all.order(:id).to_a
      metrics.each do |m|
        # look for a dupe
        metrics.each do |d|
          if m.id != d.id && m.check_id == d.check_id && m.key == d.key && d.created_at > m.created_at then
            del << d
          end
        end
      end

      del.each{ |d| d.destroy! }

      # then go through and fix all the hashes
      Metric.all.each do |m|
        tags = {}
        m.tags.each{ |t| tags[t.key] = t.value }
        m.update_tag_hash(tags)
        m.save!
      end

    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
