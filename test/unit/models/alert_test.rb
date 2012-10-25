
require "test_helper"

class Bixby::Test::Models::Alert < Bixby::Test::TestCase

  def test_for_metric
    m = FactoryGirl.create(:metric)
    a = Alert.new
    a.metric = m
    a.severity = Alert::Severity::CRITICAL
    a.threshold = 7
    a.sign = :gt
    a.save!

    aa = Alert.for_metric(m).first
    assert aa
    assert_equal aa.id, a.id
    assert_equal 7, aa.threshold
    assert_equal :gt, a.sign
  end

  def test_thresholds

    m = FactoryGirl.create(:metric)
    a = Alert.new
    a.metric = m
    a.severity = Alert::Severity::CRITICAL
    a.threshold = 7
    a.sign = :gt
    a.save!

    a = Alert.first

    assert a.test_value(45)
    refute a.test_value(7)
    refute a.test_value(6)

    a.sign = :lt
    assert a.test_value(5)
    refute a.test_value(9)

    a.sign = :ne
    assert a.test_value(8)

    a.sign = :eq
    assert a.test_value(7)

    a.sign = :ge
    assert a.test_value(7)
    assert a.test_value(8)

    a.sign = :le
    assert a.test_value(7)
    assert a.test_value(6)
    assert a.test_value(7.00000)

  end

end
