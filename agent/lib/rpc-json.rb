
class Request
  def to_json(*a)
    {
      'operation' => operation
    }.to_json(a)
  end

  def self.json_create(o)
    new(o['operation'])
  end
end

class Response
  def to_json(*a)
    {
      'return_code' => returnCode,
      'data' => data
    }.to_json(a)
  end

  def self.json_create(o)
    new(o['return_code'], o['data'])
  end
end
