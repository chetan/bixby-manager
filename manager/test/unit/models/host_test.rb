
class Bixby::Test::Models::Host < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:modules:metrics'
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_info
    host = FactoryGirl.create(:host)
    host.metadata ||= []
    host.metadata += FactoryGirl.create_list(:metadata, 2)
    host.metadata << Metadata.for("foo", "bar")

    assert_equal 3, host.metadata.size
    assert_equal 1, host.info.size
  end
end
