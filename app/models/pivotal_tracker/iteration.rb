module BusinessDomain
  module PivotalTracker
    class Iteration < Base

      has_many :iteration_stories
      has_many :stories, :through => :iteration_stories

      def self.table_name
          "pt_iterations"
      end

      # override method
      def self.parse_all
        src_data = ::PivotalTracker::Iteration
        transaction do
          arr_obj = []
          src_data.find(:all).each do |o|
            tmp = parse(o.content)
            tmp[0][:project_id] = o.project_id
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
        [:number,'number'],
        [:start,'start'],
        [:finish,'finish'],
        [:team_strength,'team_strength']]
        @@parent = '/iteration'
        super(content)
      end

    end
  end
end

