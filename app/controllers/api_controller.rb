class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:log]

  def log
    # search graph
    service, section, name = params[:service], params[:section], params[:graph]
    graph = Graph.where(:service => service, :section => section, :name => name, :secret => params[:secret]).first
    if graph.nil?
      render :json => {:message => "#{service}/#{section}/#{name} not found"}.to_json
      return
    end

    # add log
    log = Log.new(:happened_at => Time.now, :number => params[:number])
    log.graph = graph
    if log.save
      render :json => {:message => 'ok'}.to_json
    else
      render :json => {:message => 'failed'}.to_json
    end
  end
end