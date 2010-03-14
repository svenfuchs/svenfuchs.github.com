$: << File.dirname(__FILE__)

require 'jekyll'
require 'lib/aop'
require 'lib/archive'

options = {
  "permalink"   => "date", 
  "maruku"      => { "png_dir" => "images/latex", "png_engine" => "blahtex", "png_url" => "/images/latex", "use_divs" => false, "use_tex" => false },
  "lsi"         => false, 
  "destination" => File.expand_path('../..', __FILE__), 
  "markdown"    => "maruku", 
  "pygments"    => true, 
  "server"      => true, 
  "auto"        => false, 
  "source"      => File.expand_path('../../_data', __FILE__), 
  "server_port" => 4000
}

site = Jekyll::Site.new(options)

puts "Building site: #{options['source']} -> #{options['destination']}"
site.process
puts "Successfully generated site: #{options['source']} -> #{options['destination']}"
