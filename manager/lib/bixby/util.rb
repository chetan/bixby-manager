
def const_exists?(str)
  names = str.split('::')
  names.shift if names.empty? || names.first.empty?

  constant = Object
  begin
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
  rescue Exception => ex
    return false
  end
  return true
end
