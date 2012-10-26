
require "test_helper"

class Bixby::Test::Views::Models::ApiView < Bixby::Test::TestCase

  class Foo
    def initialize
      @bar = "meh"
    end
  end

  def test_convert_generic
    f = Foo.new
    h = ApiView::Engine.convert(f)
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

  private

  def run_tests(f)
    h = ApiView::Engine.convert(f)
    assert h
    assert_includes h, :bar
    assert_equal "meh", h[:bar]
  end

end
