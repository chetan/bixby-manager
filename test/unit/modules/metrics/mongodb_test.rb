
require 'test_helper'

class Bixby::Test::Modules::Metrics < Bixby::Test::TestCase
  class MongoDriver < Bixby::Test::TestCase

    def setup
      super
      Bixby::Metrics.driver = Bixby::Metrics::MongoDB
      Bixby::Metrics.driver.configure(BIXBY_CONFIG)
    end

    def test_put_and_get
      t = Time.new
      Bixby::Metrics.new.put("foobar", 37, t, {:blah => "baz"})
      m = Bixby::Metrics.new.get({:key => "foobar", :start_time => t, :end_time => t+10})

      assert m
      assert_kind_of Hash, m
      assert_equal "foobar", m[:key]
      assert_equal 1, m[:tags].size
      assert_equal "baz", m[:tags]["blah"]
      assert_equal 1, m[:vals].size
      assert_equal 37, m[:vals].first[:val].to_i
    end

  end
end
