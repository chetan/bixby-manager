
class Command

    attr_accessor :repo, :bundlebundle, :command, :args, :env

    # params hash contains:
    #   repo
    #   bundle
    #   command
    #   args (optional)
    #   env (optional)
    def initialize(params = nil)
        return if params.nil? or params.empty?
        params.each{ |k,v| self.send("#{k}=", v) }
    end

    def to_hash
        { :repo => self.repo, :bundle => self.bundle, :command => self.command,
          :args => self.args, :env => self.env }
    end

end
