
class Provisioning < BaseModule

    class << self

        def list_files(cmd)
            req = JsonRequest.new("provisioning:list_files", cmd.to_hash)
            res = req.exec()
            return res.data
        end

        def download_files(cmd, files)
            local_path = cmd.bundle_dir
            sha = Digest::SHA1.new
            #p local_path
            files.each do |f|
                # see if the file already exists
                path = File.join(local_path, f['file'])
                FileUtils.mkdir_p(File.dirname(path))
                # puts path
                next if File.file? path and f['sha1'] == sha.hexdigest(File.read(path))
                # puts "downloading file"
                req = JsonRequest.new("provisioning:fetch_file", { :cmd => cmd.to_hash, :file => f['file'] })
                req.exec_download(path)
                if f['file'] =~ /^bin/ then
                    # correct permissions for executables
                    FileUtils.chmod(0755, path)
                end
            end
        end

    end # self

end
