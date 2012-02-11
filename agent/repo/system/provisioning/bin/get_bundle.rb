#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

$: << File.expand_path(File.join(File.dirname(__FILE__), "../../../../lib"))
require "devops_agent"
require "devops_agent/api/modules/provisioning"

require "digest"
require "fileutils"

class Provision < BundleCommand

    include HttpClient

    def initialize
        super
    end

    def run!

        begin
            cmd = CommandSpec.from_json(get_json_input())
        rescue Exception => ex
            puts ex.message
            puts ex.backtrace.join("\n")
            exit 1
        end

        files = Provisioning.list_files(cmd)
        Provisioning.download_files(cmd, files)

    end

end

Provision.new.run!
