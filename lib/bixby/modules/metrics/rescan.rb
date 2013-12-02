module Bixby
class Metrics < API

  # Updates the MetricInfo (metric_infos) model
  #
  # Loads all metrics from JSON config into the database

  class RescanPlugin
    def self.update_command(cmd)

      spec = cmd.to_command_spec
      config = spec.load_config()
      base = config["key"]

      new_metrics = config["metrics"]
      return if new_metrics.blank?

      # create a hash with only the metric name (remove base)
      existing = {}
      metrics = MetricInfo.where("command_id = ?", cmd.id)
      metrics.each do |m|
        k = m.metric.gsub(/#{base}\./, '')
        existing[k] = m
      end

      # create/update metrics
      new_metrics.each do |key, metric|
        cm = existing.include?(key) ? existing[key] : MetricInfo.new
        if not cm.command_id then
          cm.command_id = cmd.id
          cm.metric = base + "." + key
        end
        cm.unit  = metric["unit"]
        cm.name  = metric["name"]
        cm.desc  = metric["desc"]
        cm.label = metric["label"]
        cm.range = metric["range"]

        platforms = metric["platforms"] || []
        cm.platforms = platforms.join(",")
        cm.save!

        Rails.logger.info "* updated metric: #{cm.metric}"
      end

    end
  end # RescanPlugin

end # Metrics
end # Bixby
