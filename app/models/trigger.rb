# == Schema Information
#
# Table name: triggers
#
#  id         :integer          not null, primary key
#  check_id   :integer
#  metric_id  :integer
#  severity   :integer
#  threshold  :decimal(20, 2)
#  status     :string(255)
#  sign       :string(2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# status: OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT

# Describes a threshold for some check or metric
class Trigger < ActiveRecord::Base

  belongs_to :check
  belongs_to :metric
  has_many :actions

  multi_tenant :via => :check

  serialize :sign, SymbolColumn.new
  serialize :status, CSVColumn.new

  module Severity
    UNKNOWN  = 0
    OK       = 1 # upon returning to normal
    WARNING  = 2
    CRITICAL = 3
  end if not const_defined? :Severity
  Bixby::Util.create_const_map(Severity)

  # sign must be one of the following
  #
  # lt  less than
  # le  less than or equal to
  # gt  greater than
  # ge  greater than or equal to
  # eq  equal
  # ne  not equal
  SIGNS = [ :lt, :le, :gt, :ge, :eq, :ne ] if not const_defined? :SIGNS

  # Find all triggers for the given Metric and it's associated Check
  #
  # @param [Metric] metric
  # @return [Array<Trigger>]
  def self.for_metric(metric)
    return Trigger.where("metric_id = ? OR check_id = ?", metric.id, metric.check_id)
  end

  # Set the severity level
  #
  # @param [String] sev     "warning" or "critical"
  def set_severity(sev)
    if sev.kind_of? Fixnum then
      self.severity = sev
    elsif sev.downcase == "warning" then
      self.severity = Severity::WARNING
    else
      self.severity = Severity::CRITICAL
    end
  end

  # Test the given value according to the set threshold & sign
  #
  # @param [Float] val    value to test
  # @return [Boolean]     true if value passes the threshold test
  def test_value(val)

    t = self.threshold

    case (self.sign)

      when :gt
        val > t

      when :ge
        val >= t

      when :lt
        val < t

      when :le
        val <= t

      when :eq
        val == t

      when :ne

        val != t

    end

  end

  # Test the given metric status against the list of statuses which will
  # fire this trigger
  #
  # @param [Metric::Status] val     as a Fixnum
  def test_status(val)
    # see if string form of Metric::Status is in list of statuses
    val = val.kind_of?(String) ? val : Metric::Status.lookup(val)
    self.status.include? val
  end

  def ok?
    self.severity == Severity::OK
  end

  def critical?
    self.severity == Severity::CRITICAL
  end

  def warning?
    self.severity == Severity::WARNING
  end

end
