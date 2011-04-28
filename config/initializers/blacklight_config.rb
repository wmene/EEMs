# You can configure Blacklight from here. 
#   
#   Blacklight.configure(:environment) do |config| end
#   
# :shared (or leave it blank) is used by all environments. 
# You can override a shared key by using that key in a particular
# environment's configuration.
# 
# If you have no configuration beyond :shared for an environment, you
# do not need to call configure() for that envirnoment.
# 
# For specific environments:
# 
#   Blacklight.configure(:test) {}
#   Blacklight.configure(:development) {}
#   Blacklight.configure(:production) {}
# 

Blacklight.configure(:shared) do |config|
  
  # FIXME: is this duplicated below?
  SolrDocument.marc_source_field  = :marc_display
  SolrDocument.marc_format_type   = :marc21
  
  # default params for the SolrDocument.search method
  SolrDocument.default_params[:search] = {
    :qt=>:search,
    :per_page => 10,
    :facets => {:fields=>
      ["format",
        "language_facet",
        "lc_1letter_facet",
        "lc_alpha_facet",
        "lc_b4cutter_facet",
        "language_facet",
        "pub_date",
        "subject_era_facet",
        "subject_geo_facet",
        "subject_topic_facet"]
    }  
  }
  
  # default params for the SolrDocument.find_by_id method
  SolrDocument.default_params[:find_by_id] = {:qt => :document}
  
  
  ##############################
  
  
  config[:default_qt] = "search_eems"
  

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "title_t",
    :heading => "title_t",
    :display_type => "format"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
    :show_link => "title_t",
    :num_per_page => 10,
    :record_display_type => "format"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display 
  config[:facet] = {
    :field_names => [
      "selectorName_facet", 
      "status_facet", 
      "paymentType_facet",
      "paymentFund_facet",
      "copyrightStatus_facet",       
      "language_facet",
      "creatorOrg_facet",
      "creatorPerson_facet"
    ],
    :labels => {
      "selectorName_facet" => "Selector", 
      "status_facet" => "Status",
      "paymentType_facet" => "Purchase",
      "paymentFund_facet" => "Fund",
      "copyrightStatus_facet" => "Copyright",
      "language_facet" => "Language",
      "creatorOrg_facet" => "Creator (organization)",
      "creatorPerson_facet" => "Creator (person)"
    }
  }

  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "title_t",
      "system_create_dt", 
      "requestDatetime_t", 
      "selectorName_t", 
      "copyrightStatus_t",
      "status_t"
    ],
    :labels => {
      "title_t" => "Title", 
      "system_create_dt" => "Created", 
      "requestDatetime_t" => "Submitted",
      "selectorName_t" => "Selector", 
      "copyrightStatus_t" => "Copyright",
      "status_t" => "Status"
    }
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "title_t",
      "sourceUrl_t",
      "language_t", 
      "creatorPerson_t",
      "creatorOrg_t", 
      "url_t", 
      "note_t",
      "copyrightStatus_t", 
      "copyrightStatusDate_t", 
      "paymentType_t",
      "paymentFund_t", 
      "selectorSunetid_t", 
      "id"
    ],
    :labels => {
      "title_t" => "Title",
      "sourceUrl_t" => "Found at this site",
      "language_t" => "Language",
      "creatorPerson_t" => "Creator",
      "creatorOrg_t" => "Creator", 
      "url_t" => "Direct link to PDF", 
      "note_t" => "Citation/Comments", 
      "copyrightStatus_t" => "Copyright", 
      "copyrightStatusDate_t" => "Copyright date", 
      "paymentType_t" => "Purchase", 
      "paymentFund_t" => "Payment fund", 
      "selectorSunetid_t" => "Selector SUNet id", 
      "id" => "Id"
    }
  }

# FIXME: is this now redundant with above?
  # type of raw data in index.  Currently marcxml and marc21 are supported.
  config[:raw_storage_type] = "marc21"
  # name of solr field containing raw data
  config[:raw_storage_field] = "marc_display"

  # "fielded" search configuration. Used by pulldown among other places.
  # For supported keys in hash, see rdoc for Blacklight::SearchFields
  config[:search_fields] ||= []
  config[:search_fields] << {:display_label => 'All Fields', :qt => 'search_eems'}
  config[:search_fields] << {:display_label => 'Title', :qt => 'title_search'}
  config[:search_fields] << {:display_label =>'Author', :qt => 'author_search'}
  config[:search_fields] << {:display_label => 'Subject', :qt=> 'subject_search'}
  
  # "sort results by" select (pulldown)
  # label in pulldown is followed by the name of the SOLR field to sort by and
  # whether the sort is ascending or descending (it must be asc or desc
  # except in the relevancy case).
  # label is key, solr field is value
  config[:sort_fields] ||= []
  config[:sort_fields] << ['title', 'title_sort asc, requestDatetime_sort desc']
  config[:sort_fields] << ['date requested', 'requestDatetime_sort desc, title_sort asc']
  config[:sort_fields] << ['created', 'system_create_dt_sort asc, title_sort asc']
  config[:sort_fields] << ['status', 'status_sort asc, title_sort asc']
  
  # If there are more than this many search results, no spelling ("did you 
  # mean") suggestion is offered.
  config[:spell_max] = 5
end

