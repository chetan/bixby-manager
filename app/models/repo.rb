# == Schema Information
#
# Table name: repos
#
#  id          :integer          not null, primary key
#  org_id      :integer
#  name        :string(255)
#  uri         :string(255)
#  branch      :string(255)
#  private_key :text
#  public_key  :text
#  created_at  :datetime
#  updated_at  :datetime
#


class Repo < ActiveRecord::Base

  belongs_to :org
  has_many :commands
  multi_tenant :via => :org

  def self.for_user(user)
    for_org(user.org_id)
  end

  def self.for_org(id)
    where(:org_id => [nil, id])
  end

  def path
    if org_id.nil? and name == "vendor" then
      File.join(Bixby.repo_path, name)
    else
      File.join(Bixby.repo_path, "#{sprintf('%04d', org_id)}_#{name}")
    end
  end

  def git?
    uri =~ /\.git$/
  end

  def svn?
    !git?
  end

  def ssh_public_key
    return SSHKey.new(self.private_key, :comment => "bixby").ssh_public_key
  end

end
