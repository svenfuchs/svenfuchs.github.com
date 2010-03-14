$: << File.dirname(__FILE__)

require 'jekyll'
require 'helpers/aop'
require 'helpers/archive'

options = {
  "permalink"   => "date", 
  "maruku"      => { "png_dir" => "images/latex", "png_engine" => "blahtex", "png_url" => "/images/latex", "use_divs" => false, "use_tex" => false },
  "lsi"         => false, 
  "destination" => "./_site", 
  "markdown"    => "maruku", 
  "pygments"    => true, 
  "server"      => true, 
  "auto"        => false, 
  "source"      => "./_data", 
  "server_port" => 4000
}

site = Jekyll::Site.new(options)

puts "Building site: #{options['source']} -> #{options['destination']}"
site.process
puts "Successfully generated site: #{options['source']} -> #{options['destination']}"
