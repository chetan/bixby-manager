
class Repo < ActiveRecord::Base

  belongs_to :org

  has_many :commands

  def path
    if org_id.nil? and name == "vendor" then
      File.join(BundleRepository.path, name)
    else
      File.join(BundleRepository.path, "#{sprintf('%04d', org_id)}_#{name}")
    end
  end

  def git?
    uri =~ /\.git$/
  end

  def svn?
    !git?
  end

end
