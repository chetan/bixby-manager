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
require 'rdoc/usage'

module CLI

    include Mixlib::CLI

    def self.included(receiver)
      receiver.extend(Mixlib::CLI::ClassMethods)
      receiver.instance_variable_set(:@options, @options)
    end

    option :directory,
        :short       => "-d DIRECTORY",
        :long        => "--directory DIRECTORY",
        :description => "Root directory for devops (default: /opt/devops)"

    def initialize
        super
        @argv = parse_options()
    end

end
