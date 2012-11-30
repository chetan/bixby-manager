# == Schema Information
#
# Table name: repos
#
#  id         :integer          not null, primary key
#  org_id     :integer
#  name       :string(255)
#  uri        :string(255)
#  branch     :string(255)
#  created_at :datetime
#  updated_at :datetime
#


class Repo < ActiveRecord::Base

  belongs_to :org

  has_many :commands

  def path
    if org_id.nil? and name == "vendor" then
      File.join(Bixby::BundleRepository.path, name)
    else
      File.join(Bixby::BundleRepository.path, "#{sprintf('%04d', org_id)}_#{name}")
    end
  end

  def git?
    uri =~ /\.git$/
  end

  def svn?
    !git?
  end

end
