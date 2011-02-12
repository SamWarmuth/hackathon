class Meal < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :restaurant_id
  view_by :restaurant_id
  
  property :date_added, :default => Proc.new{Time.now.to_i}

  def restaurant
    Restaurant.get(self.restaurant_id)
  end
  def rating
    reviews = Review.by_meal_id(:key => self.id)
    return -1 if reviews.empty?
    return (reviews.inject(0){|sum, r| sum + r.rating} / reviews.size.to_f)
    
  end
  
end
