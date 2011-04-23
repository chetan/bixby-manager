
require 'jsonify'
require 'manager'

class Command

    include Jsonify

    attr_accessor :repo, :bundle, :command, :args, :env

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

    def bundle_dir
        File.join(Manager.root, "repo", @repo, @bundle)
    end

    def bundle_exists?
        File.exists? self.bundle_dir
    end

    def command_file
        File.join(self.bundle_dir, "bin", @command)
    end

    def command_exists?
        File.exists? self.command_file
    end

end
