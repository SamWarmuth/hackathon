ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ROOT_DIR

require "rubygems"

begin
  require "vendor/dependencies/lib/dependencies"
rescue LoadError
  require "dependencies"
end

require "monk/glue"
require "couchrest"
require "haml"
require "sass"
require "json"
require "rufus/scheduler"
require "foursquare"
require "twilio"
require 'curb'


class Main < Monk::Glue
  set :app_file, __FILE__
  use Rack::Session::Cookie
end

# Connect to couchdb.
couchdb_url = monk_settings(:couchdb)[:url]
COUCHDB_SERVER = CouchRest.database!(couchdb_url)

Twilio.connect('AC9fbadee95049fa4bb1c263b9dd234045', 'ef3356cb46abcab6c1cad074cdd5436f')
FSKey = "5PO54VVOBWAO3N325SEPE030W40FFHQXNMNPFNYRJOI1M012"
FSSecret = "FQEBAIC4DXZCV11SESS54FBE0Q0S0X2STODP0WJBM3HC5U4M"
Oauth = Foursquare::OAuth.new(FSKey, FSSecret)





if defined?(Scheduler).nil?
  Scheduler = Rufus::Scheduler.start_new
  Scheduler.every "30s" do
    User.all.each do |user|
      user.create_responder("10s") if user.new_restaurant?
    end
  end
end


# Load all application files.
Dir[root_path("app/**/*.rb")].each do |file|
  require file
end

Main.run! if Main.run?
