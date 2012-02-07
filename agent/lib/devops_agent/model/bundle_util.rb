
module BundleUtil

  def uname
    @uname ||= `uname -s`.strip
  end

  def osx?
    uname == "Darwin"
  end
  alias :darwin? :osx?

  def linux?
    uname == "Linux"
  end

  def win?

  end
  alias :windows? :win?

end
