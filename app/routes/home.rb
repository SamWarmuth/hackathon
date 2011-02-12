class Main
  get "/" do
    erb :index
  end
  get "/register" do
    #request_token = oauth.request_token.token
    #request_secret = oauth.request_token.secret
    
    redirect FSOauth.request_token.authorize_url

  end
  get "/fs-register" do
    
    puts params.inspect
    return params.inspect
    access_token, access_secret = oauth.authorize_from_request(request_token, request_secret, verifier)
  end
  get "/trigger/:user_id" do
    @user = User.get(params[:user_id])
    return "Not Found" if @user.nil?
    @user.create_responder("10s")
    return "Responder created for #{@user.name}."
  end
  get "/review/:live_token" do
    @user = User.by_live_token(:key => params[:live_token]).first
    return false if @user.nil?
    
    return "Hi #{@user.name}."
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
