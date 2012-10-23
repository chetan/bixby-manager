
# Serialize a value as a JSON string
class JSONColumn
  def initialize(default={})
    @default = default
  end

  # this might be the database default and we should plan for empty strings or nils
  def load(s)
    s.present? ? MultiJson.load(s) : @default
  end

  # this should only be nil or an object that serializes to JSON (like a hash or array)
  def dump(o)
    MultiJson.dump(o || @default)
  end
end
