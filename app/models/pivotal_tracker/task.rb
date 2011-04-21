module BusinessDomain
  module PivotalTracker
    class Task < Base

      belongs_to :story

      def self.table_name
          "pt_tasks"
      end

      # override method
      def self.parse_all
        src_data = ::PivotalTracker::Task
        transaction do
          arr_obj = []
          src_data.find(:all).each do |o|
            tmp = parse(o.content)
            tmp[0][:story_id] = o.story_id
            arr_obj.push tmp
          end
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end
          end
        end
      end

      protected

      # override method
      def self.parse_content(content)
        @@params = [[:target_id,'id'],
        [:description,'description'],
        [:position,'position'],
        [:complete,'complete'],
        [:srv_created_at,'created_at']]
        @@parent = '/task'
        super(content)
      end

    end
  end
end

