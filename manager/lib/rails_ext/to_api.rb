
class Array
  def to_api(opts = {}, as_json = true)
    r = map { |e| e.to_api(opts, false) }
    return as_json ? MultiJson.dump(r) : r
  end
end

class ActiveRecord::Base

  def to_api(opts = {}, as_json = true)

    opts ||= {}
    opts[:collaborators] = true
    hash = serializable_hash(opts)

    inject = opts[:inject]
    if inject then
      inject.call(self, hash)
    end

    return as_json ? MultiJson.dump(hash) : hash
  end

end
