
require "test_helper"

class Bixby::Test::Models::Host < Bixby::Test::TestCase

  def test_to_string
    h = Host.new

    h.ip = "4.4.4.4"
    assert h.to_s
    assert_equal "4.4.4.4", h.to_s


    h.hostname = "foo.example.com"
    assert_equal "foo.example.com", h.to_s

    h.alias = "foo"
    assert_equal "foo", h.to_s
  end

  def test_info
    host = FactoryGirl.create(:host)
    host.metadata ||= []
    host.metadata += FactoryGirl.create_list(:metadata, 2)
    host.metadata << Metadata.for("foo", "bar")

    assert_equal 3, host.metadata.size
    assert_equal 1, host.info.size
  end

  def test_search_by_tag_and_kw
    host = FactoryGirl.create(:host)
    host.update_attributes({:tag_list => "foo, bar", :alias => "testing", :desc => "blarney stone"})

    # tag only
    h = Host.search("tag:foo").first
    assert h
    assert_equal host.id, h.id

    h = Host.search("tags:foo").first
    assert h
    assert_equal host.id, h.id

    h = Host.search("#foo").first
    assert h
    assert_equal host.id, h.id

    # kw only
    h = Host.search("testing").first
    assert h
    assert_equal host.id, h.id

    # tag + kw
    h = Host.search("testing tags:foo").first
    assert h
    assert_equal host.id, h.id

    # multiple tags
    h = Host.search("tag:bar tags:foo").first
    assert h
    assert_equal host.id, h.id

    # multiple tags and kw
    h = Host.search("stone tag:bar tags:foo").first
    assert h
    assert_equal host.id, h.id

    # no results
    assert_empty Host.search("asdf")
    assert_empty Host.search("tag:baz")
  end

  def test_search_by_metadata
    host = FactoryGirl.create(:host)
    host.metadata ||= []
    host.metadata += FactoryGirl.create_list(:metadata, 2)
    host.metadata << Metadata.for("foo", "bar")

    h = Host.search("foo=bar").first
    assert h
    assert_equal host.id, h.id

    # no results
    assert_empty Host.search("foo=baz")
    assert_empty Host.search("bar=baz")
  end

  def test_tenant_security

    h = FactoryGirl.create(:host)
    assert h.respond_to? :tenant
    assert h.tenant
    assert_equal h.org.tenant, h.tenant

    h2 = FactoryGirl.create(:host)
    refute_equal h.tenant, h2.tenant

    MultiTenant.current_tenant = h.tenant

    # now try to load h2 and fail
    assert_throws(MultiTenant::AccessException) do
      Host.find(h2.id)
    end

    # doesn't throw
    Host.find(h.id)

    MultiTenant.current_tenant = nil
    Host.find(h2.id)

    MultiTenant.current_tenant = h2.tenant
    Host.find(h2.id)

    # this will throw
    assert_throws(MultiTenant::AccessException) do
      Host.all
    end

  end

  def test_for_user
    h = FactoryGirl.create(:host)
    h2 = FactoryGirl.create(:host)
    u = FactoryGirl.create(:user)
    u.org = h.org
    u.save

    assert_equal h.org, u.org
    assert_equal 2, Host.all.size

    hosts = Host.all_for_user(u)
    assert_equal 1, hosts.size
    assert_equal 1, Host.for_user(u).size
    assert_equal h, hosts.first
  end

end
