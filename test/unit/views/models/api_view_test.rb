
require "helper"

class Bixby::Test::Views::Models::ApiView < Bixby::Test::TestCase

  class Foo
    def initialize
      @bar = "meh"
    end
  end

  def setup
    @user = FactoryGirl.create(:user)
    Token.create(@user)
  end

  def test_convert_generic
    f = Foo.new
    h = ApiView::Engine.convert(f, @user)
    assert_equal f, h

    Foo.class_eval do
      def serializable_hash
        return { :bar => @bar }
      end
    end
    run_tests(f)

    Foo.class_eval do
      alias_method :to_hash, :serializable_hash
    end
    run_tests(f)

    Foo.class_eval do
      alias_method :to_api, :serializable_hash
    end
    run_tests(f)
  end

  def test_hash_with_objects
    u = FactoryGirl.create(:user)
    Token.create(u)
    h = { :user => u, :foo => "bar" }

    t = ApiView::Engine.convert(h, u)
    assert_kind_of Hash, t
    assert_equal "bar", t[:foo]
    assert_kind_of Hash, t[:user]
    assert_equal u.username, t[:user][:username]
  end

  private

  def run_tests(f)
    h = ApiView::Engine.convert(f, @user)
    assert h
    assert_includes h, :bar
    assert_equal "meh", h[:bar]
  end

end
