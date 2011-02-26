
class Operation
  attr_accessor :operation_script

  def initialize(script)
    @operation_script = script
  end

  def execute
    data = `sh -c #{operation_script}`
    returnCode = $?

    return Response.new(returnCode, data).to_json
  end
end
