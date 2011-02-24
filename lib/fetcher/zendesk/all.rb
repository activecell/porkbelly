module Fetcher
  module Zendesk
    class All
      include Fetcher::Zendesk::Organization
      include Fetcher::Zendesk::Group
      include Fetcher::Zendesk::User
      include Fetcher::Zendesk::Tag
      include Fetcher::Zendesk::Forum
      include Fetcher::Zendesk::Entry
      include Fetcher::Zendesk::TicketField
      include Fetcher::Zendesk::Macro

      def initialize(credential)
        super(credential)
        raise ArgumentError, "This site required a subdomain, please specify the subdomain along with credential!" if single_fetch? && credential[:subdomain].nil?
      end

      def fetch_all
        if single_fetch?
#          fetch_organization(credential)
#          fetch_group(credential)
#          fetch_user(credential)
#          fetch_tag(credential)
          fetch_forum(credential)
          fetch_entry(credential)
#          fetch_ticket_field(credential)
#          fetch_macro(credential)
        else
          logger.info "multi fetch"
          credential.each do |cd|
            fetch_client(credential)
          end
        end
      end
    end
  end
end
