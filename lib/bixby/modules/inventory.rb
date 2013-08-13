
module Bixby

class Inventory < API

  METADATA_FACTER = 3

  # Register an Agent with the server. Also creates an associated Host record
  #
  # @param [Hash] opts
  # @option opts [String] :uuid           UUID of the host
  # @option opts [String] :public_key     Public key
  # @option opts [String] :hostname       Hostname
  # @option opts [String] :tenant         Name of the tenant
  # @option opts [String] :password       Password for registering an Agent with the server
  # @option opts [FixNum] :port           Port agent listens on (optional, default: 18000)
  # @option opts [Array<String>] :tags    List of tags to assign to host (optional)
  def register_agent(opts)

    opts = (opts||{}).with_indifferent_access
    opts[:port] ||= 18000

    t = Tenant.where(:name => opts[:tenant]).first
    if t.blank? || !t.test_password(opts[:password]) then
      if t.blank? then
        log.warn { "register_agent: tenant '#{opts[:tenant]}' not found" }
      else
        log.warn { "register_agent: tenant auth failed" }
      end
      raise API::Error, "bad tenant and/or password", caller
    end

    # TODO pass org as param
    # for now, assign to default org
    org = Org.where(:tenant_id => t.id, :name => 'default').first
    if org.nil? then
      log.warn { "org not found" }
      raise API::Error, "bad tenant and/or password", caller
    end

    # process passed in tags
    tags = opts[:tags]
    if not tags.blank? then
      if tags.kind_of? String then
        tags = tags.split(/, /)
      end
      if tags.kind_of? Array then
        tags << "new"
        tag_list = tags.sort.uniq.join(",")
      end
    end
    tag_list = "new" if tag_list.blank?

    h = Host.new
    h.org_id = org.id
    h.ip = @http_request.ip
    h.hostname = opts[:hostname]
    h.tag_list = tag_list
    h.save!

    a = Agent.new
    a.host_id = h.id
    a.ip = h.ip
    a.port = opts[:port]
    a.uuid = opts[:uuid]
    a.public_key = opts[:public_key]
    a.access_key = Bixby::CryptoUtil.generate_access_key
    a.secret_key = Bixby::CryptoUtil.generate_secret_key

    if not a.valid? then
      # validate this agent first
      msg = ""
      a.errors.keys.each { |k| msg += "; " if not msg.empty?; msg += "#{k}: #{a.errors[k]}" }
      raise API::Error, msg, caller
    end

    a.save!

    # update facts in bg (10 sec delay)
    job = Bixby::Scheduler::Job.create(Bixby::Inventory, :update_facts, h.id)
    Bixby::Scheduler.new.schedule_in(10, job)

    { :server_key => server_key_for_agent(a).public_key.to_s,
      :access_key => a.access_key,
      :secret_key => a.secret_key }
  end

  # Update Facter facts on the given Host or Agent
  #
  # @param [Host] host      to update
  def update_facts(host)

    agent = agent_or_host(host)

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/inventory",
                               :command => "list_facts.rb" )

    ret = exec(agent, command)
    if ret.error? then
      return ret # TODO
    end

    ActiveRecord::Base.transaction do
      facts = ret.decode
      metadata = {}

      agent.host.metadata ||= []
      agent.host.metadata.each { |m| metadata["#{m.key}_#{m.source}"] = m }

      facts.each do |k,v|
        mk = "#{k}_#{METADATA_FACTER}"
        if metadata.include?(mk) then
          metadata[mk].value = v
          metadata[mk].save!
        else
          m = Metadata.for(k, v, METADATA_FACTER)
          agent.host.metadata << m
        end
      end

      agent.host.save!
    end

    true
  end

  # Update the version number of the currently running Bixby agent
  #
  # @param [Host] host      to update
  def update_version(host)
    agent = agent_or_host(host)
    logger.debug "got agent"
    logger.debug agent
    command = CommandSpec.new(:repo => "vendor", :bundle => "system/inventory",
                              :command => "get_agent_version.rb")

    ret = exec(agent, command)
    if ret.error? then
      return ret # TODO
    end

    return if ret.stdout.blank?

    agent.version = ret.stdout.strip
    agent.save!
  end

end

end # Bixby
