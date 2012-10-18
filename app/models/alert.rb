
# Describes an alerting threshold
class Alert < ActiveRecord::Base

  belongs_to :check
  belongs_to :metric


  # alert sign must be one of the following
  #
  # lt  less than
  # le  less than or equal to
  # gt  greater than
  # ge  greater than or equal to
  # eq  equal
  # ne  not equal
  SIGNS = [ :lt, :le, :gt, :ge, :eq, :ne ]

  # Find all alerts for the given Metric and it's associated Check
  #
  # @param [Metric] metric
  # @return [Array<Alert>]
  def self.for_metric(metric)
    return Alert.where("metric_id = ? OR check_id = ?", metric.id, metric.check_id)
  end

  # Test the given value according to the set threshold & sign
  #
  # @param [Float] val    value to test
  # @return [Boolean]     true if value passes the threshold test
  def test(val)

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

end
