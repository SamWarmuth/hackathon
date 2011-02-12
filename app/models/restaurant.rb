class Restaurant < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :fs_id
  property :lat
  property :long
  property :address
  property :city
  property :state
  property :zip

  property :date_added, :default => Proc.new{Time.now.to_i}
  def meals
    Meal.by_restaurant(:key => self.id)
  end
  def top_meals
    
  end
  
end
