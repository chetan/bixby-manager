
module Bixby
  module Util

  # Test if the given constant name exists
  #
  # @param [String] str       name of the constant to test
  #
  # @return [Boolean] true if it exists
  def self.const_exists?(str)
    names = str.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    begin
      names.each do |name|
        constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
      end
    rescue Exception => ex
      return false
    end
    return true
  end

  # Create a map of the constants in the given Module
  #
  # Adds a new constant called CONST_MAP as well as a helper method called lookup
  #
  # @example for Metric::Status -
  #
  #   Metric::Status::CONST_MAP = {
  #     :UNKNOWN   => 0,
  #     "UNKNOWN"  => 0,
  #     :OK        => 1,
  #     "OK"       => 1,
  #     :WARNING   => 2,
  #     "WARNING"  => 2,
  #     :CRITICAL  => 3,
  #     "CRITICAL" => 3,
  #     :TIMEOUT   => 4,
  #     "TIMEOUT"  => 4,
  #     0          => "UNKNOWN",
  #     1          => "OK",
  #     2          => "WARNING",
  #     3          => "CRITICAL",
  #     4          => "TIMEOUT"
  #   }
  #
  #   Metric::Status.lookup(3)      => "CRITICAL"
  #   Metric::Status.lookup("OK")   => 1
  #   Metric::Status.lookup(:OK)    => 1
  #   Metric::Status["OK"]          => 1
  #
  # @param [Module] mod
  def self.create_const_map(mod)
    return if mod.const_defined? :CONST_MAP

    map = {}
    mod.constants.each do |k|
      v = mod.const_get(k)
      map[k] = v
      map[k.to_s] = v
      map[v] = k.to_s if !map.include? v
    end

    mod.const_set(:CONST_MAP, map)
    mod.class_eval do
      def self.lookup(id)
        if id.kind_of? String then
          id.upcase!
        elsif id.kind_of? Symbol then
          id = id.to_s.upcase.to_sym
        end
        self.const_get(:CONST_MAP)[id]
      end
      class << self
        alias_method :[], :lookup
      end
    end

  end

  end # Util
end # Bixby
