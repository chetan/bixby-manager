
require "helper"

class Bixby::Test::Models::Host < Bixby::Test::TestCase

  def test_to_string
    h = Host.new

    h.ip = "4.4.4.4"
    assert h.to_s
    assert_equal "4.4.4.4", h.to_s


    h.hostname = "foo.example.com"
    assert_equal "foo.example.com", h.to_s

    h.alias = "foo"
    assert_equal "foo.example.com", h.to_s
  end

  def test_info
    host = FactoryGirl.create(:host)
    host.metadata ||= []
    host.add_metadata("uptime", "34 days")
    host.add_metadata("frob", "nicate")
    host.add_metadata("foo", "bar")
    host.save

    assert_equal 3, host.metadata.size
    assert_equal 1, host.info.size

    h = Host.find(host.id)
    assert_equal 3, h.metadata.size
    assert_equal 1, h.info.size
  end

  def test_search_by_tag_and_kw
    host = FactoryGirl.create(:agent).host
    user = FactoryGirl.create(:user)
    user.org = host.org
    user.save

    host.update_attributes({:tag_list => "foo, bar", :alias => "testing", :desc => "blarney stone"})

    # tag only
    h = Host.search("tag:foo", user).first
    assert h
    assert_equal host.id, h.id

    h = Host.search("tags:foo", user).first
    assert h
    assert_equal host.id, h.id

    h = Host.search("#foo", user).first
    assert h
    assert_equal host.id, h.id

    # kw only
    h = Host.search("testing", user).first
    assert h
    assert_equal host.id, h.id

    # tag + kw
    h = Host.search("testing tags:foo", user).first
    assert h
    assert_equal host.id, h.id

    # multiple tags
    h = Host.search("tag:bar tags:foo", user).first
    assert h
    assert_equal host.id, h.id

    # multiple tags and kw
    h = Host.search("stone tag:bar tags:foo", user).first
    assert h
    assert_equal host.id, h.id

    # no results
    assert_empty Host.search("asdf", user)
    assert_empty Host.search("tag:baz", user)
  end

  def test_search_by_metadata
    host = FactoryGirl.create(:agent).host
    user = FactoryGirl.create(:user)
    user.org = host.org
    user.save

    host.metadata ||= []
    host.add_metadata("uptime", "34 days")
    host.add_metadata("kernel", "darwin")
    host.add_metadata("foo", "bar")

    # create an extra agent/host
    FactoryGirl.create(:agent).host.tap { |h| h.org = host.org; h.save }

    hosts = Host.search("foo=bar", user)
    assert_equal 1, hosts.size
    h = hosts.first
    assert h
    assert_equal host.id, h.id

    # alternate form
    hosts = Host.search("foo:bar", user)
    assert_equal 1, hosts.size
    h = hosts.first
    assert h
    assert_equal host.id, h.id

    # no results
    assert_empty Host.search("foo=baz", user)
    assert_empty Host.search("bar=baz", user)
  end

  def test_search_inactive
    host = FactoryGirl.create(:agent).host
    user = FactoryGirl.create(:user)
    user.org = host.org
    user.save

    # create an extra host that's inactive (no agent attached)
    inactive_host = FactoryGirl.create(:host).tap { |h| h.org = host.org; h.save }

    hosts = Host.for_user(user)
    assert_equal 1, hosts.size

    hosts = Host.for_user(user, true)
    assert_equal 2, hosts.size

    hosts = Host.search("is:inactive", user)
    assert_equal 1, hosts.size
    assert_equal inactive_host.id, hosts.first.id
  end

  def test_for_user
    h = FactoryGirl.create(:agent).host
    h2 = FactoryGirl.create(:agent).host
    u = FactoryGirl.create(:user)
    u.org = h.org
    u.save

    assert_equal h.org, u.org
    assert_equal 2, Host.all.size

    hosts = Host.for_user(u)
    assert_equal 1, hosts.size
    assert_equal 1, Host.for_user(u).size
    assert_equal h, hosts.first
  end

end
