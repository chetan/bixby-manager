
module Bixby

  class CommandResponse
    attr_accessor :log

    # Create a new CommandResponse from the given JsonResponse
    #
    # @param [JsonResponse] res
    #
    # @return [CommandResponse]
    def self.from_json_response(res)
      cr = CommandResponse.new(res.data)
      if res.fail? then
        if !(res.message.nil? || res.message.empty?) then
          cr.status ||= UNKNOWN_FAILURE
          cr.stderr ||= res.message
        else
          cr.status ||= UNKNOWN_FAILURE
        end
      end
      cr.log = res.log # tack on the CommandLog
      cr
    end
  end

end
