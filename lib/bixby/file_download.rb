
module Bixby

  # Describes a response which triggers a send_file()
  class FileDownload

    attr_accessor :filename

    def initialize(file)
      @filename = file
    end

  end

end
