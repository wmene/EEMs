require 'active_fedora'

module Dor
  class Utils
    def self.register_local
      Fedora::Repository.register(FEDORA_URL)
      ActiveFedora::SolrService.register(SOLR_URL)
    end
  end
end