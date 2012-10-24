
# Serialize a Symbol value to string and back
class SymbolColumn
  # this might be the database default and we should plan for empty strings or nils
  def load(s)
    s.present? ? s.to_sym : s
  end

  # this should only be nil or a symbol
  def dump(o)
    o.to_s
  end
end
