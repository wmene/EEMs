class ContentFile < ActiveRecord::Base
      
  #needs to save percent done to object in db
  def update_progress(dl_total, dl_now)
    done_now = (Float(dl_now) / Float(dl_total) * 100).round
    update_attribute(:percent_done, done_now) if(done_now != percent_done)
  rescue FloatDomainError => e
    # ignore the initial 0.0/0.0 
  end
  
end
