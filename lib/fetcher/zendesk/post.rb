module Fetcher
  module Zendesk
    module Post
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys, :entrys

      def load_entry_ids(credential)
        zendesk_entry = ::Zendesk::Entry
        @entries = zendesk_entry.where(:credential => extract_credential(credential))
      end

      def fetch_post(credential)
        load_entry_ids(credential)
        ::Zendesk::Entry.transaction do
          @entries.each do |f|
            doc = Nokogiri::XML(f.content)
            @content_keys = extract_content_post_keys(doc.xpath("entry/posts").to_s)
            format_param = ZENDESK_CONFIG["format"].to_s
            entry_id = f.target_id
            begin
              save_post_data(@content_keys,  format_param, credential, entry_id)
            rescue Exception => e
              #TODO send email
              puts e
              puts e.backtrace
            end
            logger.info "Updated data"
          end
        end
      end

      #save data to database after checking for existing record
      def save_post_data(content_keys, format_param, credential, entry_id)
        content_keys.each do |content_key|
          data = content_key.values[0]
          extracted_key = content_key.keys[0].to_s
          zendesk_user =  ::Zendesk::Post.find_or_initialize_by_target_id(extracted_key)
          zendesk_user.update_attributes({:content => data, :format => format_param, :credential => extract_credential(credential), :target_id => extracted_key, :entry_id => entry_id})
        end
      end

      def extract_content_post_keys(response)
        doc = Document.new response
        extracted_keys = Array.new
        for i in 1..doc.root.elements.size do
          key_value_pair = {doc.root.elements[i].elements["id"].text.to_i => doc.root.elements[i].to_s}
          extracted_keys[i-1] = key_value_pair
        end
        extracted_keys
      end
    end
  end
end

