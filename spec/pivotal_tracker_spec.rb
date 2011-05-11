# Run all Mixpanel unit test!
Dir[File.dirname(__FILE__) + '/pivotal_tracker_spec/*_spec.rb'].each {|file| 
  require file
}
