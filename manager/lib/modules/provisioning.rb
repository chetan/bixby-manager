
require 'find'
require 'digest'

require 'command'

module Provisioning

    class << self

        # returns an array of hashes: [{ :file, :sha1 }]
        def list_files(params)

            cmd = Command.from_json(params)
            sha = Digest::SHA1.new

            files = []
            root = File.join(cmd.bundle_dir, "")
            Find.find(root) do |path|
                next if path == root or not File.file? path
                files << { :file => path.gsub(root, ""), :sha1 => sha.hexdigest(File.read(path)) }
            end

            return files
        end

        def fetch_file(params)

            cmd = Command.from_json(params["cmd"])
            file = params["file"]

            path = File.join(cmd.bundle_dir, file)
            if File.file? path then
                return FileDownload.new(path)
            end

            return nil
        end

    end

end
