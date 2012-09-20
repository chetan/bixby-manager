
require 'test_helper'

class Bixby::Test::RailsExt::JSONColumn < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:rails_ext:json_column'
  end

  def test_dump_and_load
    c = FactoryGirl.create(:command)
    c.options = { :foo => "bar", "baz" => 32 }
    c.save!
    assert c.id

    c = Command.find(c.id)
    assert c

    opts = c.options
    assert opts
    assert_kind_of Hash, opts
    assert opts.include? "foo"
    assert_equal "bar", opts["foo"]
  end

end
