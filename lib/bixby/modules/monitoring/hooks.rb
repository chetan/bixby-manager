
module Bixby
class Monitoring < API

  module Hooks

    extend Bixby::Log

    Bixby::Inventory.add_hook(:register_agent) do |agent|
      add_checks_on_register(agent)
    end

    # Apply Check Template rules to the newly registered agent
    #
    # @param [Agent] agent
    def self.add_checks_on_register(agent)

      # Get all check templates and test agent's tags against them
      cts = CheckTemplate.where(:org_id => agent.org.id)
      return if cts.blank?

      # tags = agent.host.tags.inject({}){ |h,t| h[t.name] = 1; h }
      tags = Set.new(agent.host.tags.map{|t| t.name})
      p tags

      cts.each do |ct|
        ctags = Set.new(ct.tags.split(/,/))


        apply = false
        common = tags.intersection(ctags)

        if !common.empty? then
          logger.warn "any?"
          if CheckTemplate::Mode::ANY == ct.mode then
            apply = true
          elsif CheckTemplate::Mode::ALL == ct.mode && tags.intersection(ctags).size == ctags.size then
            logger.warn "all"
            apply = true
          end
        elsif CheckTemplate::Mode::EXCEPT == ct.mode then
          logger.warn "except"
          apply = true
        end

        if apply then
          logger.warn "applying checks"
          ct.items.each do |item|
            Bixby::Monitoring.new.add_check(agent.host, item.command, item.args, agent)
          end
        end

      end

    end

  end

end
end
