
module EemsHelper

  # Get text field tag for a property
  def eems_text_field_tag(prop, value = '', options = {})
    text_field_tag "eem[#{prop.to_s}]", value, options 
  end

  # Get value for a given eem field
  def print_eems_field(name, msg = '') 
    if (!@eem.nil?)
      value = eval("@eem.fields[:#{name.to_s}][:values].first")
    end
    
    if (value.nil? || value.empty?)
      value = msg
    end
    
    return value
  end 

  # Get value for a given eem part field
  def print_parts_field(name, msg = '') 
    value = ''
    
    if (!@parts[0].nil?)
      value = eval("@parts[0].datastreams['properties'].#{name.to_s}_values.first")
    end
  
    if (value.nil? || value.empty?)
      value = msg
    end
    
    return value
  end
  
  # Print the url decoded
  def print_url_decoded
    url = print_parts_field('url')
    URI::decode(url)
  end 

  # Get source URL from referrer (or return empty string if nil)
  def get_source_url(referrer)
    value = ''
    
    if !referrer.nil? && !referrer.empty?
      value = referrer
    end
    
    return value
  end

  # Get shortened source URL (max length = 50 characters)
  def shorten_url(url)
    max_length = 40
    
    if url.length > max_length
      url = url[0, max_length] + '...'
    end
    
    return url
  end  

  # Get creator name (value from either creatorOrg or creatorPerson)
  def get_creator_name
    value = ''
    creator_person = @eem.fields[:creatorPerson][:values].first
    creator_org = @eem.fields[:creatorOrg][:values].first
    
    if (!creator_person.nil? && !creator_person.empty?)
      value = creator_person
    end  

    if (!creator_org.nil? && !creator_org.empty?)
      value = creator_org
    end  
    
    return value
  end

  # Get creator type (either 'person' or 'organization')
  def get_creator_type
    value = 'organization'
    creator_person = @eem.fields[:creatorPerson][:values].first
    
    if (!creator_person.nil? && !creator_person.empty?)
      value = 'person'
    end  
    
    return value
  end

  # Get locally saved filename 
  def get_local_filename
    fname = ''
    
    if (!@parts[0].nil?)
      value = @parts[0].datastreams['properties'].filename_values.first
      fname = value unless(value.nil?)
    end

    return fname
  end
  
  # Get URL/path to the locally saved filename
  def get_local_file_path 
    value = 'unknown'
    filename = URI::escape(get_local_filename())
    
    if (!filename.empty?)
      value = Sulair::WORKSPACE_URL + '/' + @eem.pid + '/' + filename
    end  
    
    return value
  end

  # Get payment fund (or empty string if nil)
  def get_payment_fund
    value = ''
    payment_type = print_eems_field('paymentType')
    
    if (payment_type == 'Paid')
      value = print_eems_field('paymentFund')
    end
    
    return value
  end

  # escape html tags (<, >)
  def escape_tags(value)
    value = value.gsub(/>/, '&gt;')     
    value = value.gsub(/</, '&lt;')    
    
    return value
  end     
    
  # Get catkey for detail page
  def get_catkey
    catkey = ''
    
    @eem.datastreams['DC'].identifier_values.each do |value|
      if value && value =~ /catkey:(\w+)/i
        catkey = $1
      end
    end
    
    return catkey  
  end
  
  # get part pid
  def get_part_pid 
    if (!@eem.parts.first.nil?)
      return @eem.parts.first.pid
    end
    
    return ''
  end
  
  
  # check if the eem is editable (i.e., eem is not sent to tech services)
  def is_eem_editable(status)    
    if status =~ /Created/i
      return true
    end    
    
    return false
  end

  # check if the eem is canceled 
  def is_eem_canceled(status)    
    if status =~ /Canceled/i
      return true
    end    
    
    return false
  end


  # get external language name from given code
  def get_language_name(code) 
    language = {
      'ara' => 'Arabic', 'chi' => 'Chinese', 'eng' => 'English', 'fre' => 'French', 
      'ger' => 'German', 'heb' => 'Hebrew', 'ita' => 'Italian', 'jpn' => 'Japanese', 
      'kor' => 'Korean', 'rus' => 'Russian', 'spa' => 'Spanish', '|||' => 'Other'
    }
    
    return language[code] || code
  end
    
  # format action log timestamp
  def format_action_log_timestamp(timestamp)
    if !timestamp.nil?
      return timestamp.strftime("%d-%b-%Y %I:%M %p")
    end
    
    return ''
  end
  
  # format action log message
  def format_action_log_message(msg)    
    if (!msg.nil? && msg =~ /^(.*? (by|for) )(.*)$/)
      msg = $1 + '<a href="/?f%5BselectorName_facet%5D%5B%5D=' + $2 + '">' + $3 + '</a>'
    end
    
    return msg || ''
  end

  # format download date timestamp to store in part child object
  def format_download_date_timestamp(timestamp)
    if !timestamp.nil?
      return timestamp.strftime("%Y-%m-%dT%H:%M%z")
    end
    
    return ''
  end
    
end
