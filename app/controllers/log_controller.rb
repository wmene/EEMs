class LogController < ApplicationController
  before_filter :require_fedora
  before_filter :require_solr

  # It can handle json 
  # {"entry": "My log entry text", "comment": "My comment about this entry"}
  # 
  # Or xml
  # <log>
  #  <entry>My xml entry</entry>
  #  <comment>My comment about this entry</comment>
  # </log>
  #
  # Or application/x-www-form-urlencoded
  #  entry=My%20text
  def create
    eem = Eem.find(params[:eems_id])
    log = eem.datastreams['actionLog']
    log.log(params[:entry], params[:comment])
    log.save
    
    render :text => 'logged'
  end
end