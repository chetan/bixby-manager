
require 'test_helper'

class Bixby::Test::Modules::Metrics < Bixby::Test::TestCase
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

      tms = t.to_i*1000

      stub = stub_request(:post, "http://localhost:8080/api/v1/datapoints/query").
        with{ |req| req.body =~ /foobar/ && req.body.include?(tms.to_s) }.
        to_return(:status => 200, :body => '{"queries":[{"results":[{"name":"foobar","tags":{"blah":["baz"]},"values":[[1375189490000,3.200000047683716],[1375189940000,3.200000047683716]]}]}]}', :headers => {})

      m = Bixby::Metrics.new.multi_get([{:key => "foobar", :start_time => t.to_i, :end_time => (t+10).to_i}])
      assert_requested stub
      assert_metric m
    end

    def test_get_by_tag
      # first invalid tag
      stub = stub_request(:post, "http://localhost:8080/api/v1/datapoints/query").
        with{ |req| req.body =~ /foobar/ }.
        to_return {
          { :status => 200, :body => %q/{"errors":["failed"]}/ }
        }

      ret = Bixby::Metrics.new.get({ :key => "foobar", :start_time => (Time.new.to_i-86400*7), :end_time => Time.new.to_i, :tags => {:foo => "baz"} })
      refute ret

      stub_request(:post, "http://localhost:8080/api/v1/datapoints/query").
        with{ |req| req.body =~ /foobar/ }.
        to_return(:status => 200, :body => '{"queries":[{"results":[{"name":"foobar","tags":{"blah":["baz"]},"values":[[1375189490000,3.200000047683716],[1375189940000,3.200000047683716]]}]}]}', :headers => {})

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
