#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "/../../../../lib/agent"))

require "server/json_request"
require "server/json_response"
require "api/modules/provisioning"

require "digest"
require "fileutils"

class Provision < BundleCommand

    include HttpClient

    def initialize
        super
    end

    def run!

        begin
            cmd = Command.from_json(ARGV.join(" "))
        rescue Exception => ex
            puts "failed"
            exit
        end

        files = Provisioning.list_files(cmd)
        Provisioning.download_files(cmd, files)

    end

end

Provision.new.run!
