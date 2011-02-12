class User < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :email
  property :phone_number
  
  
  
  property :fs_token
  
  property :after_time, :default => Proc.new{Time.now.to_i} #The date that the last restaurant was visited, so we don't hit them twice.
  
  property :live_token
  view_by :live_token
  
  property :challenges
  
  
  property :current_restaurant_id
  
  def restaurant
    Restaurant.get(self.current_restaurant_id)
  end

  def new_restaurant?    
    #is the user in a new restaurant?
    raw = JSON.parse(Curl::Easy.perform("https://api.foursquare.com/v2/users/self/checkins?oauth_token=#{self.fs_token}").body_str)['response']
    return false if raw.nil? || raw['checkins'].nil?
    checkins = raw['checkins']['items']
    new_checkins = checkins.find_all{|c| (c['createdAt'].to_i > self.after_time) && (c['venue']['categories'].first['parents'].first == "Food")}.sort_by{|c| -(c['createdAt'].to_i)}
    
    new_restaurant = new_checkins.first
    if new_restaurant.nil?
      return false
    else
      puts "New Restaurant!"
      
      restaurant = Restaurant.all.find{|r| r.fs_id == new_restaurant['venue']['id']}
      if restaurant.nil?
        restaurant = Restaurant.new
        venue = new_restaurant['venue']
        restaurant.name = venue['name']
        restaurant.fs_id = venue['id']
        restaurant.address = venue['location']['address']
        restaurant.city = venue['location']['city']
        restaurant.state = venue['location']['state']
        restaurant.zip = venue['location']['postalCode']
        restaurant.save
      end
      self.current_restaurant_id = restaurant.id
      self.save
      return true
    end
  end
  
  def create_responder(time = "45m")
    self.live_token = 8.times.map{|l|('a'..'z').to_a[rand(25)]}.join
    self.after_time = Time.now.to_i
    self.save
    puts "creating responder"
    from_number = "4155992671" #twilio sandbox number
    Twilio::Sms.message(from_number, self.phone_number, "The top meals are #{self.current_restaurant.top_meals.map{|m| m.name + "("+m.rating+")"}}.")
    
    Scheduler.in time do
      puts "sent text"
      Twilio::Sms.message(from_number, self.phone_number, "How's the food at #{self.restaurant.name}? Review it here: http://www.whatsbesthere.com/review/#{self.live_token}.")
      puts "Send text with url 'www.whatsbesthere.com/review/#{self.live_token}'"
    end
  end
  
end