class Main
  get "/" do
    erb :index
  end

  get "/place" do
    erb :place
  end
  get "/rate-it" do
    erb :rateit
  end
  get "/best-stuff" do
    erb :beststuff
  end
  get "/how-it-works" do
    erb :howitworks
  end
  get "/terms-and-privacy" do
    erb :termsandprivacy
  end
  
  get '/register' do
    redirect "https://foursquare.com/oauth2/authenticate?client_id=#{FSKey}&response_type=code&redirect_uri=http://localhost:4567/fs-register"
  end
  
  get '/fs-register' do
    user_code = params[:code]
    c = Curl::Easy.perform("https://foursquare.com/oauth2/access_token?client_id=#{FSKey}&client_secret=#{FSSecret}&grant_type=authorization_code&redirect_uri=http://localhost:4567/fs-register&code=#{user_code}")
    user = User.first
    user.fs_token = JSON.parse(c.body_str)["access_token"]
    user.save
    redirect "/checkins"
  end
  
  get '/checkins' do
    user = User.first
    puts user.fs_token
    checkins = JSON.parse(Curl::Easy.perform("https://api.foursquare.com/v2/users/self/checkins?oauth_token=#{user.fs_token}").body_str)['response']
    pretty =  checkins['checkins']['items'].map{|checkin| checkin['venue']['name'] + " ("+checkin['venue']['categories'].first['parents'].first+") - " + Time.at(checkin['createdAt'].to_i).to_s}.join("<br/>")
    
    return pretty + "<br/><br/><br/>" + checkins.inspect
  end

  
  get "/trigger/:user_id" do
    @user = User.get(params[:user_id])
    return "Not Found" if @user.nil?
    @user.create_responder("10s")
    return "Responder created for #{@user.name}."
  end
  get "/restaurants" do
    @restaurants = Restaurant.all
    erb :restaurants
  end
  get "/review/:live_token" do
    @user = User.by_live_token(:key => params[:live_token]).first
    return false if @user.nil?
    
    return "Hi #{@user.name}.<br/><br/><br/> What did you get at #{@user.restaurant.name}, and how did you like it?<br/><br/><br/>Post back to this url to store."
  end
  post "/review/:live_token" do
    @user = User.by_live_token(:key => params[:live_token]).first
    return false if @user.nil?
    review = Review.new
    
    
    @user.live_token = nil
    @user.save
    
    return "Successfully Rated"

  end
end
