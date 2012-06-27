
require "bixby_agent/model/bundle_util"

require "digest"
require "fileutils"

require 'mixlib/cli'

module Bixby
class BundleCommand

  include BundleUtil
  include Jsonify

  include Mixlib::CLI

  option :help,
      :short          => "-h",
      :long           => "--help",
      :description    => "Print this help",
      :boolean        => true,
      :show_options   => true,
      :exit           => 0

  def initialize(options=nil)
    @agent = Agent.create
    if not @skip_parse then
      super()
      @argv = parse_options()
    end
  end

  # retrieve all loaded subclasses of this classs
  #
  # @return [Array<Class>] List of subclasses
  def self.subclasses
    @subclasses
  end

  # Reads JSON data from STDIN
  #
  # @return [Object] data found on STDIN (can be Hash, Array, String, etc)
  def get_json_input
    input = read_stdin()
    input.strip! if input
    (input.nil? or input.empty?) ? {} : MultiJson.load(input)
  end

  # Read all available data on STDIN without blocking
  # (i.e., if no data is available, none will be returned)
  #
  # @return [String] data
  def read_stdin
    buff = []
    while true do
      begin
        buff << STDIN.read_nonblock(64000)
      rescue => ex
        break
      end
    end
    return buff.join('')
  end

  private

  def self.inherited(subclass)
    subclass.extend(Mixlib::CLI::ClassMethods)
    subclass.instance_variable_set(:@options, @options)
    if superclass.respond_to? :inherited
      superclass.inherited(subclass)
    end
    @subclasses ||= []
    @subclasses << subclass
  end

end # BundleCommand
end # Bixby

