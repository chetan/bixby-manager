
module Bixby
module BundleUtil

  def uname
    RUBY_PLATFORM
  end

  def osx?
    uname =~ /darwin/
  end
  alias :darwin? :osx?
  alias :mac? :osx?

  def linux?
    uname =~ /linux/
  end

  def win?

  end
  alias :windows? :win?

end # BundleUtil
end # Bixby
