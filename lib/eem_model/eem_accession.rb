# Copied from internal Stanford gem

require 'nokogiri'

module EemModel
  module EemAccession

    # create a datastream in the repository for the given eem object
    def populate_datastream(ds_name)
      label = case ds_name
        when "identityMetadata" then 'Identity Metadata'
        when "contentMetadata" then 'Content Metadata'
        when "rightsMetadata" then 'Rights Metadata'
        else ''
      end
      metadata = case ds_name
        when "identityMetadata" then generate_identity_metadata_xml
        when "contentMetadata" then generate_content_metadata_xml
        when "rightsMetadata" then generate_rights_metadata_xml
        else nil
      end
      unless( metadata.nil? )
        populate_datastream_in_repository(ds_name,label,metadata)
      end
    end

    # create a datastream for the given eem object with the given datastream name, label, and metadata blob
    def populate_datastream_in_repository(ds_name,label,metadata)
      attrs = { :pid => pid, :dsID => ds_name, :mimeType => 'application/xml', :dsLabel => label, :blob => metadata }
      datastream = ActiveFedora::Datastream.new(attrs)
      datastream.control_group = 'M'
      datastream.versionable = false
      datastream.save
    end

    # create the identity metadata xml datastream
    #
    #   <identityMetadata>
    #     <objectId>druid:rt923jk342</objectId>                                   <-- Fedora PID
    #     <objectType>item</objectType>                                           <-- Supplied fixed value
    #     <objectLabel>value from Fedora header</objectLabel>                     <-- from Fedora header
    #     <objectCreator>DOR</objectCreator>                                      <-- Supplied fixed value
    #     <citationTitle>title, from DC:title</citationTitle>                     <-- updated after Symphony record is created
    #     <citationCreator>creator, from DC:creator</citationCreator>             <-- updated after Symphony record is created
    #     <otherId name="dissertationid">0000000012</otherId>                     <-- per Registrar, from EEM propertied <dissertationid>
    #     <otherId name="catkey">129483625</otherId>                              <-- added after Symphony record is created. Can be found in DC
    #     <otherId name="uuid">7f3da130-7b02-11de-8a39-0800200c9a66</otherId>     <-- DOR assigned (omit if not present)
    #     <agreementId>druid:ct692vv3660</agreementId>                            <-- fixed pre-assigned value, use the value shown here for EEMs
    #     <tag>EEM : Dissertation | Thesis</tag>                                  <-- set of tags *
    #   </identityMetadata>
    #
    # == Options
    # - <b>:add_label</b> If set to <i>true</i>, will add objectLabel to the xml, based on the Fedora object label.  Default is <i>false</i>
    def generate_initial_identity_metadata_xml(options={:add_label => false})
      builder = Nokogiri::XML::Builder.new do |xml|
        dc_ds = datastreams['DC']
        props_ds = datastreams['eemsProperties']
        xml.identityMetadata {
          xml.objectId {
            xml.text(pid)
          }
          xml.objectType {
            xml.text("item")
          }
          if(options[:add_label])
            xml.objectLabel{
              xml.text(self.label)
            }
          end
          xml.objectAdminClass {
            xml.text("EEMs")
          }
          xml.agreementId {
            xml.text("some:objectId")
          }
          xml.tag {
            xml.text("EEM : 1.0" )
          }
        }
      end
      builder.to_xml
    end
  
    def update_identity_metadata_object_label
      id_ds = datastreams['identityMetadata']
      id_xml = id_ds.content
      if(!id_xml.nil? && !id_xml.empty?)
        id_doc = Nokogiri::XML(id_xml)
        object_label = id_doc.at_xpath('//objectLabel')
        # create a new one if it doesn't exist
        if(object_label.nil?)
          object_label = Nokogiri::XML::Node.new('objectLabel', id_doc)
          object_label.content = self.label
          object_type = id_doc.at_xpath('//objectType')
          if(object_type)
            object_type.add_next_sibling(object_label)
          else
            id_doc.root << object_label
          end
        # else replace the old label with the new label  
        elsif(object_label.content != self.label)
          object_label.content = self.label
        end
        id_ds.content = id_doc.to_xml
      
      # Create identityXml datastream since it doesn't exist
      else
         id_ds.content = generate_initial_identity_metadata_xml(:add_label => true)
      end
    
      id_ds.save
    
    end

    # create the content metadata xml datastream
    #
    #   <contentMetadata type="eem" objectId="druid:rt923jk342">
    #     <resource id="main" type="main-original" data="content">
    #       <attr name="label">Body of dissertation (as submitted)</attr>
    #       <file id="mydissertation.pdf" mimetype="application/pdf" size="758621" shelve="yes" deliver="no" preserve="yes" />
    #     </resource>
    #     <resource id="main" type="main-augmented" data="content" objectId="druid:ck234ku2334">
    #       <attr name="label">Body of dissertation</attr>
    #       <file id="mydissertation-augmented.pdf" mimetype="application/pdf" size="751418" shelve="yes" deliver="yes" preserve="yes">
    #         <location type="url">https://stacks.stanford.edu/file/druid:rt923jk342/mydissertation-augmented.pdf</location>
    #       </file>
    #     </resource>
    #     <resource id="supplement" type="supplement" data="content" sequence="1" objectId="druid:pt747ce6889">
    #       <attr name="label">Full experimental data</attr>
    #       <file id="datafile.xls" mimetype="application/ms-excel" size="83418" shelve="yes" deliver="yes" preserve="yes">
    #         <location type="url">https://stacks.stanford.edu/file/druid:rt923jk342/datafile.xls</location>
    #       </file>
    #     </resource>
    #     <resource id="permissions" type="permissions" data="content" objectId="druid:wb711pm9935">
    #       <attr name="label">Permission from the artist</attr>
    #       <file id="xyz-permission.txt" mimetype="application/text" size="341" shelve="yes" deliver="no" preserve="yes" />
    #     </resource>
    #   </contentMetadata>
    #
    def generate_content_metadata_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.contentMetadata(:type => "eem", :objectId => pid) {
          # main pdf
          props_ds = main_pdf.datastreams['properties']
          main_pdf_file_name = props_ds.file_name_values.first
          main_pdf_file_size = props_ds.size_values.first
          xml.resource(:id => "main", :type => "main-original", :data => "content") {
            xml.attr(:name => "label") {
              xml.text("Body of dissertation (as submitted)")
            }
            xml.file(:id => main_pdf_file_name, :mimetype => "application/pdf", :size => main_pdf_file_size, :shelve => "yes", :deliver => "no", :preserve => "yes")
          }
          # augmented pdf
          props_ds = main_pdf.datastreams['properties']
          main_pdf_file_name = props_ds.file_name_values.first
          main_pdf_file_size = props_ds.size_values.first
          augmented_pdf_file_name = main_pdf_file_name.gsub(/\.pdf/,'-augmented.pdf')
          augmented_pdf_file_size = File.size?(File.join(WORKSPACE_DIR, pid, augmented_pdf_file_name))
          xml.resource(:id => "main", :type => "main-augmented", :data => "content", :objectId => main_pdf.pid) {
            xml.attr(:name => "label") {
              xml.text("Body of dissertation")
            }
            xml.file(:id => augmented_pdf_file_name, :mimetype => "application/pdf", :size => augmented_pdf_file_size, :shelve => "yes", :deliver => "yes", :preserve => "yes") {
              xml.location(:type => "url") {
                xml.text("https://stacks.stanford.edu/file/#{pid}/#{augmented_pdf_file_name}")
              }
            }
          }
          # supplemental files
          supplemental_files.each_with_index do |supplemental_file, sequence|
            props_ds = supplemental_file.datastreams['properties']
            supplemental_file_name = props_ds.file_name_values.first
            supplemental_file_mimetype = MIME::Types.type_for(supplemental_file_name).first.content_type
            supplemental_file_label = props_ds.label_values.first
            supplemental_file_size = props_ds.size_values.first
            xml.resource(:id => "supplement", :type => "supplement", :data => "content", :sequence => sequence+1, :objectId => supplemental_file.pid) {
              xml.attr(:name => "label") {
                xml.text(supplemental_file_label)
              }
              xml.file(:id => supplemental_file_name, :mimetype => supplemental_file_mimetype, :size => supplemental_file_size, :shelve => "yes", :deliver => "yes", :preserve => "yes") {
                xml.location(:type => "url") {
                  xml.text("https://stacks.stanford.edu/file/#{pid}/#{supplemental_file_name}")
                }
              }
            }
          end
          # permission files
          permission_files.each_with_index do |permission_file, sequence|
            props_ds = permission_file.datastreams['properties']
            permission_file_name = props_ds.file_name_values.first
            permission_file_mimetype = MIME::Types.type_for(permission_file_name).first.content_type
            permission_file_label = props_ds.label_values.first
            permission_file_size = props_ds.size_values.first
            xml.resource(:id => "permissions", :type => "permissions", :data => "content", :objectId => permission_file.pid) {
              xml.attr(:name => "label") {
                xml.text(permission_file_label)
              }
              xml.file(:id => permission_file_name, :mimetype => permission_file_mimetype, :size => permission_file_size, :shelve => "yes", :deliver => "no", :preserve => "yes")
            }
          end
        }
      end
      builder.to_xml
    end

    # create the rights metadata xml datastream
    #
    #   <rightsMetadata objectId="druid:rt923jk342">
    #     <copyright>
    #       <human>(c) Copyright [conferral year] by [student name]</human>
    #     </copyright>
    #     <access type="discover">                                        <--- this block is static across EEMs; all EEMs are discoverable
    #       <machine>
    #         <world />
    #       </machine>
    #     </access>
    #     <access type="read">                                            <--- include this block after an object has been "released"
    #       <machine>
    #         <group>stanford:stanford</group> -OR- <world />             <--- for Stanford-only access or world/public visibility
    #         <embargoReleaseDate>2011-03-01</embargoReleaseDate>         <--- if embargoed, date calculated from release date
    #       </machine>
    #     </access>
    #     <use>
    #       <machine type="creativeCommons" type="code">value</machine>   <--- if a license is selected
    #     <use>
    #   </rightsMetadata>
    #
    def generate_rights_metadata_xml
    
      # determine which parts of the rights metadata should be displayed based on the workflow lifecycle
      is_shelved = false
      shelve_status = Dor::WorkflowService.get_workflow_status(pid,'eemAccessionWF','shelve')
      if( "#{shelve_status}".eql? "completed" )
        is_shelved = true
      end

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.rightsMetadata(:objectId => pid) {
          props_ds = datastreams['properties']
          conferral_year = props_ds.degreeconfyr_values.first
          student_name = props_ds.name_values.first
          xml.copyright {
            xml.human {
              formatted_student_name = Dor::Util.parse_name(student_name)
              xml.text("(c) Copyright #{conferral_year} by #{formatted_student_name}")
            }
          }
          xml.access(:type => "discover") {
            xml.machine {
              xml.world
            }
          }
          if( is_shelved )
            release_date = get_embargo_date
            visibility = props_ds.external_visibility_values.first
            generate_rights_access_block(xml,release_date,visibility)
          end
          cc_license_type = props_ds.cclicensetype_values.first
          cc_code = props_ds.cclicense_values.first
          cc_license = case cc_code
            when "1" then 'by'
            when "2" then 'by-sa'
            when "3" then 'by-nd'
            when "4" then 'by-nc'
            when "5" then 'by-nc-sa'
            when "6" then 'by-nc-nd'
            else 'none'
          end
          unless( cc_license.nil? and cc_license_type.nil? )
            xml.use {
              xml.machine(:type => "creativeCommons") {
                xml.text(cc_license)
              }
              xml.human(:type => "creativeCommons") {
                xml.text(cc_license_type)
              }
            }
          end
        }
      end
      builder.to_xml
    end

    def generate_rights_access_block(xml,release_date,visibility)
      access_type = 'stanford'
      if( visibility == '100' and (!release_date.nil? and release_date.past?) )
        access_type = 'world'
      end
      xml.access(:type => "read") {
        xml.machine {
          if( access_type.eql? 'stanford' )
            xml.group {
              xml.text("stanford")
            }
            if( !release_date.nil? && release_date.future? )
              xml.embargoReleaseDate {
                xml.text(release_date.strftime("%Y-%m-%d"))
              }
            end
          else
            xml.world
          end
        }
      }
    end

  end
end

