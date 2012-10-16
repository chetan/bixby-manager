
class HostsController < ApplicationController

  resource_description do
    name 'Hosts'
    short 'Hosts'
    path '/hosts'
    version '1.0'
    formats ['json']
    error :code => 401, :desc => "Unauthorized"
    description <<-DOC
      Host CRUD operations
    DOC
  end


  api :GET, "/hosts", "List all hosts"
  description "List all hosts, optionally filtering by query params"
  param :q, String, :desc => "query string"
  example " 'host': {...} "
  see "hosts#index"

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


  api :GET, "/hosts/:id", "Show a specific host"
  param :id, Fixnum, :desc => "Host id", :required => true
  example " 'host': {...} "
  see "hosts#show"

  def show
    @host = Host.find(params[:id])
    restful @host
  end


  api :PUT, "/hosts/:id", "Update a host"
  param :id, Fixnum, :desc => "Host id", :required => true
  example " 'host': {...} "
  see "hosts#update"

  def update
    @host = Host.find(params[:id])
    attrs = pick(:alias, :desc)
    attrs[:tag_list] = params[:tags]
    @host.update_attributes(attrs)

    restful @host
  end


  api :DELETE, "/hosts/:id", "Decommission a host"
  param :id, Fixnum, :desc => "Host id", :required => true
  example " 'host': {...} "
  see "hosts#destroy"

  def destroy
    @host = Host.find(params[:id])
    @host.destroy
    @host.agent.destroy if @host.agent

    restful @host
  end

end
