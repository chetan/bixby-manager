
# Serialize a list of values to a CSV
class CSVColumn
  def initialize(default=[])
    @default = default
  end

  # this might be the database default and we should plan for empty strings or nils
  def load(s)
    s.present? ? s.split(/,/) : @default
  end

  # this should only be nil or an array of values
  def dump(o)
    (o || @default).join(',')
  end
end
