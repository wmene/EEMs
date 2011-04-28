# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
  
  def application_name
    'EEMs'
  end

  def render_document_heading
    '<h1>' + document_heading.to_s + '</h1>'
  end
  
  def eem_title_heading
    @document['title_t'].first
  end
    
  # Get value for a given eem field
  def print_solr_field(name, msg = '') 
    value = eval("@document[:#{name.to_s}]")
    
    if (value.nil? || value.empty?)
      value = msg
    end
    
    value
  end 

  # Get facet display name
  def get_facet_display_value(fname, value)
    if (fname == 'language_facet')
      value = get_language_name(value)
    end
    
    value
  end      
  
  # Get formatted timestamp for search results
  def format_search_results_timestamp(timestamp)        
    if !timestamp.nil?
      time = Time.parse(timestamp) 
      return time.strftime("%d-%b-%Y")
    end
        
    return ''    
  end
  
  # Get sort values for header element in dashboard -> search results
  def get_sort_params(field) 
    sort = params["sort"] 
    css_class = ""
    field = field.sub(/_t$/, '');
        
    if sort =~ /#{field}_sort[\s\+]asc/
      sort = sort.sub(/#{field}_sort[\s\+]asc/, "#{field}_sort desc")
      css_class = "searchResultsHdrSortDesc"
            
    elsif sort =~ /#{field}_sort[\s\+]desc/
      sort = sort.sub(/#{field}_sort[\s\+]desc/, "#{field}_sort asc")
      css_class = "searchResultsHdrSortAsc"      
      
    else 
      sort = get_default_sort(field)
    end 
    
    return [sort, css_class]
  end
  
  # Get default sort string for solr fields
  def get_default_sort(field) 
    default_sort = {
      "title" => "title_sort asc",
      "system_create_dt" => "system_create_dt_sort desc", 
      "requestDatetime" => "requestDatetime_sort desc", 
      "selectorName" => "selectorName_sort asc", 
      "copyrightStatus" => "copyrightStatus_sort asc",
      "status" => "status_sort asc"      
    }
    
    return default_sort[field] || ''
    
  end
  
end

