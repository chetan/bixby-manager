
require 'helper'

require 'bixby/modules/metrics/mongodb'

class Bixby::Test::Modules::Metrics < Bixby::Test::TestCase
  class MongoDriver < Bixby::Test::TestCase

    def setup
      super
      Bixby::Metrics.driver = Bixby::Metrics::MongoDB
      Bixby::Metrics.driver.configure(BIXBY_CONFIG)
    end

    def teardown
      super
      Bixby::Metrics::MongoDB::MetricData.delete_all
    end

    def test_put_and_get
      t = Time.new
      Bixby::Metrics.new.put("foobar", 37, t, {:blah => "baz"})
      m = Bixby::Metrics.new.get({:key => "foobar", :start_time => t, :end_time => t+10})

      assert_metric m
    end

    def test_get_by_time_int_string
      t = Time.new
      Bixby::Metrics.new.put("foobar", 37, t, {:blah => "baz"})
      m = Bixby::Metrics.new.get({:key => "foobar", :start_time => t.to_i.to_s, :end_time => (t+10).to_i})

      assert_metric m
    end

    def test_get_by_tag
      t = Time.new
      Bixby::Metrics.new.put("foobar", 37, t, {:blah => "baz", :host_id => 42})

      # search by 1 tag
      m = Bixby::Metrics.new.get({
        :key => "foobar", :start_time => t, :end_time => t+10,
        :tags => {:blah => "baz"}})

      assert_metric m, 2

      # search by multiple tags
      # pass host_id as a string to simulate how its retrieved by the metadata class
      # since it treats all stored values as strings
      m = Bixby::Metrics.new.get({
        :key => "foobar", :start_time => t, :end_time => t+10,
        :tags => {:blah => "baz", :host_id => "42"}})

      assert_metric m, 2

      # no hits by tag
      m = Bixby::Metrics.new.get({
        :key => "foobar", :start_time => t, :end_time => t+10,
        :tags => {:blah => "bar"}})

      refute m
    end

    private

    def assert_metric(m, num_tags=1)
      assert m
      assert_kind_of Hash, m
      assert_equal "foobar", m[:key]
      assert_equal num_tags, m[:tags].size
      assert_equal "baz", m[:tags]["blah"]
      assert_equal 1, m[:vals].size
      assert_equal 37.0, m[:vals].first[:val]
    end

  end
end
