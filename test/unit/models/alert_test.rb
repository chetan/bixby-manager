
require "test_helper"

class Bixby::Test::Models::Alert < Bixby::Test::TestCase

  def setup
    super
    SimpleCov.command_name 'test:modules:metrics'
  end

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
    a.threshold = 7
    a.sign = :gt

    assert a.test(45)
    refute a.test(7)
    refute a.test(6)

    a.sign = :lt
    assert a.test(5)
    refute a.test(9)

    a.sign = :ne
    assert a.test(8)

    a.sign = :eq
    assert a.test(7)

    a.sign = :ge
    assert a.test(7)
    assert a.test(8)

    a.sign = :le
    assert a.test(7)
    assert a.test(6)
    assert a.test(7.00000)

  end

end
