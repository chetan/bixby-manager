
require 'helper'

require 'bixby/modules/metrics/kairosdb'

module Bixby::Test::Modules::MetricDrivers
  class KairosDriver < Bixby::Test::TestCase

    def setup
      super
      Bixby::Metrics.driver = Bixby::Metrics::KairosDB
      Bixby::Metrics.driver.configure(BIXBY_CONFIG)
    end

    def test_put_and_get
      t = Time.new
      stub_socket(t)
      Bixby::Metrics.new.put("foobar", 37, t, {:blah => "baz"})

      ret = [{"name"=>"foobar", "tags"=>{"blah"=>["baz"]}, "values"=>[[1375189490000, 3.200000047683716], [1375189940000, 3.200000047683716]]}]
      Continuum::KairosDB.any_instance.stubs(:multi_get).with{ |opts|
        o = opts.first
        o[:key] == "foobar" && o[:start_time] == t.to_i*1000 && o[:end_time] == (t.to_i+10)*1000
      }.returns(ret)

      m = Bixby::Metrics.new.multi_get([{:key => "foobar", :start_time => t.to_i, :end_time => (t+10).to_i}])
      assert_metric m
    end

    def test_get_by_tag
      # first invalid tag
      Continuum::KairosDB.any_instance.expects(:get).with{ |opts| opts[:key] == "foobar" }.returns([])
      ret = Bixby::Metrics.new.get({ :key => "foobar", :start_time => (Time.new.to_i-86400*7), :end_time => Time.new.to_i, :tags => {:foo => "baz"} })
      refute ret

      # then correct result
      ret = {"name"=>"foobar", "tags"=>{"blah"=>["baz"]}, "values"=>[[1375189490000, 3.200000047683716], [1375189940000, 3.200000047683716]]}
      Continuum::KairosDB.any_instance.stubs(:get).with{ |opts| opts[:key] == "foobar" }.returns(ret)

      ret = Bixby::Metrics.new.get({ :key => "foobar", :start_time => (Time.new.to_i-86400*7), :end_time => Time.new.to_i, :tags => {:foo => "bar"} })
      assert ret
      assert_kind_of Hash, ret
      refute_empty ret
      assert_metric [ret]

    end


    private

    def stub_socket(t)
      mock = mock()
      TCPSocket.expects(:new).with("localhost", 4242).returns(mock)
      mock.stubs(:sendmsg).with{ |v| v =~ /foobar/ and v.include? t.to_i.to_s }
    end

    def assert_metric(m, num_tags=1)
      assert m
      m = m.shift
      assert_kind_of Hash, m
      assert_equal "foobar", m[:key]
      assert_equal num_tags, m[:tags].size
      assert_equal "baz", m[:tags]["blah"]
      assert_equal 2, m[:vals].size
      assert_equal 3.200000047683716, m[:vals].first[:val].to_f
      assert_equal 1375189490, m[:vals].first[:time]
    end

  end
end
