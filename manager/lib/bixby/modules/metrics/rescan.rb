module Bixby
class Metrics < API

  class RescanPlugin
    def self.update_command(cmd)

      spec = cmd.to_command_spec
      config = spec.load_config()
      base = config["key"]

      # create a hash with only the metric name (remove base)
      existing = {}
      metrics = CommandMetric.where("command_id = ?", cmd.id)
      metrics.each do |m|
        k = m.metric.gsub(/#{base}\./, '')
        existing[k] = m
      end

      # create/update metrics
      new_metrics = config["metrics"]
      new_metrics.each do |key, metric|
        cm = existing.include?(key) ? existing[key] : CommandMetric.new
        if not cm.command_id then
          cm.command_id = cmd.id
          cm.metric = base + "." + key
        end
        cm.unit = metric["unit"]
        cm.desc = metric["desc"]
        cm.save!

        Rails.logger.info "* updated metric: #{cm.metric}"
      end

    end
  end # RescanPlugin

end # Metrics
end # Bixby
