class Dish < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :restaurant_id
  view_by :restaurant_id
  
  property :date_added, :default => Proc.new{Time.now.to_i}

  def restaurant
    Restaurant.get(self.restaurant_id)
  end
  
end
