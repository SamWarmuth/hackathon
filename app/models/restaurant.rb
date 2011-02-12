class Dish < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :lat
  property :long
  property :address
  property :city
  property :state
  property :zip

  property :date_added, :default => Proc.new{Time.now.to_i}
  
end
