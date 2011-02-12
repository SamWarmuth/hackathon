class User < CouchRest::ExtendedDocument
  use_database COUCHDB_SERVER
  
  property :name
  property :email
  property :phone_number
  
  property :foursquare_token
  
  property :after_time #The date that the last restaurant was visited, so we don't hit them twice.
  
  property :live_token
  view_by :live_token

  def new_restaurant?
    #is the user in a new restaurant?
    self.after_time = Time.now.to_i
    self.save
  end
  
  def create_responder(time = "45m")
    self.live_token = 8.times.map{|l|('a'..'z').to_a[rand(25)]}.join
    self.save
    
    Scheduler.in time do
      from_number = "4155992671" #twilio sandbox number
      Twilio::Sms.message(from_number, self.phone_number, "http://www.whatsbesthere.com/review/#{self.live_token}")
      puts "Send text with url 'whatsbesthere.com/review/#{self.live_token}'"
    end
  end
  
end