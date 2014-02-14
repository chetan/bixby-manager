
module Bixby
class Monitoring < API

  module Hooks

    extend Bixby::Log

    Bixby::Metrics.add_hook(:put_check_result) do |metrics|
      test_metrics(metrics)
    end

    Bixby::Inventory.add_hook(:register_agent) do |agent|
      add_checks_on_register(agent)
    end

    # Test the given list of metrics for triggers
    #
    # @param [Array<Metric>] metrics
    def self.test_metrics(metrics)

      all_triggers = get_all_triggers(metrics)
      metrics.each do |metric|

        triggers = all_triggers.find_all { |a|
          a.metric_id == metric.id or a.check_id == metric.check_id
        }
        next if triggers.blank?

        triggered = []
        reset = []

        triggers.each do |trigger|
          logger.debug { "testing #{metric.key}: #{metric.last_value} #{trigger.sign} #{trigger.threshold.to_s}" }
          if trigger.test_value(metric.last_value) or trigger.test_status(metric.last_status) then
            # trigger is over threshold
            if trigger.severity == metric.status then
              next # already in this state, skip
            end
            logger.debug { "#{metric.key}: triggered" }
            triggered << trigger

          elsif metric.status != Metric::Status::OK then
            # trigger has returned to normal
            logger.debug { "#{metric.key}: reset" }
            reset << trigger
          end
        end # triggers.each

        # process triggers over threshold
        filter_triggers(triggered).each do |trigger|
          # store history
          history = TriggerHistory.record(metric, trigger)
          metric.status = trigger.severity
          metric.save!

          # process all actions
          trigger.actions.each do |action|
            if action.alert? then
              # notify
              oncall = OnCall.find(action.target_id)
              MonitoringMailer.alert(metric, trigger, oncall.current_user).deliver

            elsif action.exec? then
              # run command
              cmd = Command.find(action.target_id)
              # TODO run it
            end
          end
        end # triggered

        # only proceed if all triggers did not match
        next if not triggered.blank?

        # metric is back to normal level
        filter_triggers(reset).each do |trigger|
          metric.status = Metric::Status::OK
          metric.save!
          previous_history = TriggerHistory.previous_for_trigger(trigger)
          history = TriggerHistory.record(metric, trigger)

          # process all actions
          trigger.actions.each do |action|
            if action.alert? then
              # notify
              oncall = OnCall.find(action.target_id)
              MonitoringMailer.alert(metric, trigger, oncall.current_user).deliver
            end
            # we ignore exec actions for now
          end
        end # reset

      end # metrics.each
    end # test_metrics()

    # Apply Check Template rules to the newly registered agent
    #
    # @param [Agent] agent
    def self.add_checks_on_register(agent)

      # Get all check templates and test agent's tags against them
      cts = CheckTemplate.where(:org_id => agent.org.id)
      return if cts.blank?

      # tags = agent.host.tags.inject({}){ |h,t| h[t.name] = 1; h }
      tags = Set.new(agent.host.tags.map{|t| t.name})

      update = false
      cts.each do |ct|
        apply = false
        ctags = Set.new(ct.tags.split(/,/))
        common = tags.intersection(ctags)

        if !common.empty? then
          if CheckTemplate::Mode::ANY == ct.mode then
            apply = true
          elsif CheckTemplate::Mode::ALL == ct.mode && common.size == ctags.size then
            apply = true
          end
        elsif CheckTemplate::Mode::EXCEPT == ct.mode then
          apply = true
        end

        if apply then
          update = true
          ct.items.each do |item|
            Bixby::Monitoring.new.add_check(agent.host, item.command, item.args, agent)
          end
        end

      end

      if update then
        # update checks in bg (no delay)
        Bixby::Monitoring.defer.update_check_config(agent.id)
      end

    end # self.add_checks_on_register

    private


    # Filter the given list of triggers
    # * If any are CRITICAL, returns only those
    # * Otherwise returns all (no filtering done)
    #
    # @param [Array<Trigger>] triggers
    #
    # @return [Array<Trigger>] filtered list of triggers
    def self.filter_triggers(triggers)
      if triggers.size > 1 then
        # get only CRITICAL triggers
        filtered = triggers.find_all { |t| t.severity == Trigger::Severity::CRITICAL }
      end
      if filtered.blank? then
        filtered = triggers
      end
      return filtered
    end

    # Get all triggers matching the list of metrics (in a single query)
    def self.get_all_triggers(metrics)
      metric_ids = []
      check_ids = []
      metrics.each do |m|
        metric_ids << m.id
        check_ids << m.check_id
      end

      return Trigger.where("metric_id IN (?) OR check_id IN (?)",
                           metric_ids,
                           check_ids.sort.uniq)
    end


  end # Hooks

end
end
