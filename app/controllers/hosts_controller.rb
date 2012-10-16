
class HostsController < ApplicationController

  resource_description do
    name 'Hosts'
    short 'Hosts'
    path '/hosts'
    version '1.0 - 3.4.2012'
    formats ['json', 'xml']
    param :id, Fixnum, :desc => "User ID", :required => false
    param :user, Hash, :desc => 'Param description for all methods' do
      param :username, String, :required => true,
            :desc => "Username for login"
      param :password, String, :required => true,
            :desc => "Password for login"
    end
    description <<-DOC
      Full description of this resource.
    DOC
  end

  def index
    query = params[:q] || params[:query]
    if not query.blank? then
      @hosts = Host.search(query)
    else
      @hosts = Host.all
    end
    bootstrap @hosts
    restful @hosts
  end

  def show
    @host = Host.find(params[:id])
    restful @host
  end

  def update
    @host = Host.find(params[:id])
    attrs = pick(:alias, :desc)
    attrs[:tag_list] = params[:tags]
    @host.update_attributes(attrs)

    restful @host
  end

  def destroy
    @host = Host.find(params[:id])
    @host.destroy
    @host.agent.destroy if @host.agent

    restful @host
  end

end
