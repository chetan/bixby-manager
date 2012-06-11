# == Synopsis
#   This is a sample description of the application.
#   Blah blah blah.
#
# == Examples
#   This command does blah blah blah.
#     ruby_cl_skeleton foo.txt
#
#   Other examples:
#     ruby_cl_skeleton -q bar.doc
#     ruby_cl_skeleton --verbose foo.html
#
# == Usage
#   ruby_cl_skeleton [options] source_file
#
#   For help use: ruby_cl_skeleton -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -V, --verbose       Verbose output
#   TO DO - add additional options
#
# == Author
#   YourName
#
# == Copyright
#   Copyright (c) 2007 YourName. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'mixlib/cli'
require 'optparse'

module Bixby
class App

module CLI

  include Mixlib::CLI

  def self.included(receiver)
    receiver.extend(Mixlib::CLI::ClassMethods)
    receiver.instance_variable_set(:@options, @options)
  end

  option :password,
      :short          => "-P PASSWORD",
      :long           => "--password PASSWORD",
      :description    => "Agent registration password"

  option :directory,
      :short          => "-d DIRECTORY",
      :long           => "--directory DIRECTORY",
      :default        => "/opt/devops",
      :description    => "Root directory for devops (default: /opt/devops)"

  option :port,
      :short          => "-p PORT",
      :long           => "--port PORT",
      :default        => Bixby::Server::DEFAULT_PORT,
      :description    => "Port agent will listen on (default: #{Bixby::Server::DEFAULT_PORT})"

  option :debug,
      :long           => "--debug",
      :description    => "Enable debugging messages",
      :boolean        => true

  option :help,
      :short          => "-h",
      :long           => "--help",
      :description    => "Print this help",
      :boolean        => true,
      :show_options   => true,
      :exit           => 0

  def initialize
    super
    @argv = parse_options()
  end

end # CLI

end # App
end # Bixby
