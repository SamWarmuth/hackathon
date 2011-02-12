class Main
  get "/" do
    if logged_in? == false
      @new_user = true
      @user = User.new
      @user.save
      set_cookies
    end
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
    logged_in?
    redirect "https://foursquare.com/oauth2/authenticate?client_id=#{FSKey}&response_type=code&redirect_uri=http://whatsbest.samwarmuth.com/fs-register"
  end
  
  get '/fs-register' do
    logged_in?
    user_code = params[:code]
    c = Curl::Easy.perform("https://foursquare.com/oauth2/access_token?client_id=#{FSKey}&client_secret=#{FSSecret}&grant_type=authorization_code&redirect_uri=http://whatsbest.samwarmuth.com/fs-register&code=#{user_code}")
    @user.fs_token = JSON.parse(c.body_str)["access_token"]
    @user.save
    redirect "/checkins"
  end
  
  get '/checkins' do
    logged_in?
    puts @user.fs_token
    checkins = JSON.parse(Curl::Easy.perform("https://api.foursquare.com/v2/users/self/checkins?oauth_token=#{@user.fs_token}").body_str)['response']
    pretty =  checkins['checkins']['items'].map{|checkin| checkin['venue']['name'] + " ("+checkin['venue']['categories'].first['parents'].first+") - " + Time.at(checkin['createdAt'].to_i).to_s}.join("<br/>")
    
    return pretty + "<br/><br/><br/>" + checkins.inspect
  end

  
  get "/trigger/:user_id" do
    @user = User.get(params[:user_id])
    return "Not Found" if @user.nil?
    @user.create_responder("10s")
    return "Responder created for #{@user.name}."
  end
  
  
  get "/all-restaurants" do
    logged_in?
    @restaurants = Restaurant.all
    haml :all_restaurants
  end
  
  
  get "/review/:live_token" do
    @user = User.by_live_token(:key => params[:live_token]).first
    return false if @user.nil?
    
    haml :review
  end
  
  
  post "/review/:live_token" do
    @user = User.by_live_token(:key => params[:live_token]).first
    return false if @user.nil?
    review = Review.new
    meal = Meal.by_name(:key => params[:meal]).first
    if meal.nil?
      meal = Meal.new
      meal.name = params[:meal]
    end
    review.meal_id = meal.id
    review.user_id = @user.id
    review.rating = params[:rating].to_i
    review.save
    
    
    @user.live_token = nil
    @user.save
    
    return "Successfully Rated"

  end
end
