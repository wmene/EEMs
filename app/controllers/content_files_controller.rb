require 'delayed_job'

class ContentFilesController < ApplicationController
  before_filter :find_model
  
  def show
    pdone = {'percent_done' => @cf.percent_done.to_s}
    if(@cf.attempts == Delayed::Worker.max_attempts + 1)
      pdone['attempts'] = 'failed'
    else
      pdone['attempts'] = @cf.attempts.to_s
    end
    
    Rails.logger.debug("pdone: #{pdone.inspect}")
    render :json => pdone.to_json 

  end

  private
  def find_model
    ContentFile.uncached do
      @cf = ContentFile.find(params[:id]) if params[:id]
    end
  end
end
