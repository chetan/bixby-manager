
class Provisioning < BaseModule

    class << self

        def list_files(cmd)
            req = JsonRequest.new("provisioning:list_files", cmd.to_hash)
            res = req.exec()
            return res.data
        end

        def download_files(cmd, files)
            local_path = cmd.bundle_dir
            digest = cmd.load_digest
            files.each do |f|

                fetch = true
                if not digest then
                    fetch = true
                elsif df = digest["files"].find{ |h| h["file"] == f["file"] } then
                    # compare digest w/ stored one if we have it
                    fetch = (df["digest"] != f["digest"])
                else
                    fetch = true
                end

                next if not fetch

                params = cmd.to_hash
                params.delete(:digest)

                path = File.join(local_path, f['file'])
                req = JsonRequest.new("provisioning:fetch_file", [ params, f['file'] ])
                req.exec_download(path)
                if f['file'] =~ /^bin/ then
                    # correct permissions for executables
                    FileUtils.chmod(0755, path)
                end
            end
        end

    end # self

end
