class Review < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :user_id
  property :meal_id
  view_by :meal_id
  property :rating
  property :date, :default => Proc.new{Time.now.to_i}

  def user
    User.get(self.user_id)
  end
  def restaurant
    Meal.get(self.meal_id).restaurant
  end
  def meal
    Meal.get(self.meal_id)
  end
  
end
