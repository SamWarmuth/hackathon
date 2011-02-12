class Review < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :user_id
  property :dish_id
  property :rating
  property :date, :default => Proc.new{Time.now.to_i}

  def user
    User.get(self.user_id)
  end
  def restaurant
    Dish.get(self.dish_id).restaurant
  end
  def dish
    Dish.get(self.dish_id)
  end
  
end
