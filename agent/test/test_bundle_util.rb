require 'helper'

module Bixby
module Test

  class TestBundleUtil < TestCase

    def test_util
      if `uname` =~ /Darwin/ then
        assert FooUtil.new.osx?
        refute FooUtil.new.linux?
      end
    end

  end

  class FooUtil
    include BundleUtil
  end

end
end
