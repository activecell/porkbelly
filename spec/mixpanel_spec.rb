# Run all Mixpanel unit test!
Dir[File.dirname(__FILE__) + '/mixpanel_spec/*_spec.rb'].each {|file| 
  require file
}
