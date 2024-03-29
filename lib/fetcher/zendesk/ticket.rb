module Fetcher
  module Zendesk
    module Ticket
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys, :views

      def load_view_ids(credential)
        zendesk_view = ::Zendesk::View
        @views = zendesk_view.where(:credential => extract_credential(credential))
      end

      def fetch_ticket(credential)
        load_view_ids(credential)
        ::Zendesk::View.transaction do
          @views.each do |f|
            f_id = f.target_id
            page_number = 0
            request_url =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + ZENDESK_CONFIG["apis"]["tickets"] + "/" + f_id.to_s  + "." +  ZENDESK_CONFIG["format"]
            items_count = f.per_page
            while items_count == f.per_page #get next page for pagination
              page_number += 1
              request_url_pagination = request_url + "?page=#{page_number}"
              response = create_request(credential, request_url_pagination)
              logger.info "Created request url: #{request_url}"
              logger.info response.get.to_s
              @content_keys = extract_content_ticket_keys(response.get)
              format_param = ZENDESK_CONFIG["format"].to_s
              request_url_param = request_url_pagination.to_s
              view_id = f_id
              doc = Nokogiri::XML(response.get)
              items_count = doc.xpath("/tickets/@count").text
              begin
                save_ticket_data(@content_keys, request_url_param, format_param, credential, view_id)
                save_view_ticket_data(@content_keys,view_id,credential)
              rescue Exception => e
                #TODO send email
                puts e
                puts e.backtrace
              end
              logger.info "Updated data"
            end
          end
        end
      end

      #save data to database after checking for existing record
      def save_ticket_data(content_keys, request_url_param, format_param, credential, view_id)
        content_keys.each do |content_key|
          extracted_key = content_key.keys[0]
          request_url_ticket =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + "/tickets/" + extracted_key.to_s  + "." +  ZENDESK_CONFIG["format"]
          extracted_key = extracted_key.to_s + '--' + credential[:subdomain].to_s
          data = create_request(credential, request_url_ticket).get
          zendesk_ticket =  ::Zendesk::Ticket.find_or_initialize_by_target_id(extracted_key)
          logger.info zendesk_ticket.inspect
          zendesk_ticket.update_attributes({:request_url => request_url_param, :content => data, :format => format_param, :credential => extract_credential(credential), :target_id => extracted_key, :subdomain => credential[:subdomain]})
        end
      end
#      save to src_view_tickets
      def save_view_ticket_data(content_keys,view_id,credential)
        content_keys.each do |content_key|
          extracted_key = content_key.keys[0]
          extracted_key = extracted_key.to_s + '--' + credential[:subdomain].to_s
          zendesk_ticket =  ::Zendesk::ViewTicket.find_or_initialize_by_view_id_and_ticket_id_and_credential(view_id.to_s,extracted_key.to_s,extract_credential(credential))
          zendesk_ticket.save
        end
      end

      def extract_content_ticket_keys(response)
        doc = Document.new response
        extracted_keys = Array.new
        for i in 1..doc.root.elements.size do
          key_value_pair = {doc.root.elements[i].elements["nice-id"].text.to_i => doc.root.elements[i].to_s}
          extracted_keys[i-1] = key_value_pair
        end
        extracted_keys
      end
    end
  end
end

