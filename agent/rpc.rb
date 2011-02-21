class Request
  attr_accessor :operation
  
  def initialize(operation)
    @operation = operation
  end
end

class Response
  attr_accessor :returnCode, :data
  
  def initialize(returnCode, data)
    @returnCode = returnCode
    @data = data
  end
end
