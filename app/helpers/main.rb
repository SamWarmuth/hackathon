class Main
  helpers do
    def logged_in?
      return false unless request.cookies.has_key?("user_challenge") && request.cookies.has_key?("user")
      user = User.get(request.cookies['user'])
      
      return false if user.nil?
      return false unless user.challenges && user.challenges.include?(request.cookies['user_challenge'])

      @user = user
      return true
    end
    def set_cookies
      return false if @user.nil?
      @user.challenges ||= []
      @user.challenges = @user.challenges[0...4]
      @user.challenges.unshift((Digest::SHA2.new(512) << (64.times.map{|l|('a'..'z').to_a[rand(25)]}.join)).to_s)
      @user.save
      
      response.set_cookie("user", {
        :path => "/",
        :expires => Time.now + 2**20, #two weeks
        :httponly => true,
        :value => @user.id
      })
      response.set_cookie("user_challenge", {
        :path => "/",
        :expires => Time.now + 2**20,
        :httponly => true,
        :value => @user.challenges.first
      })
    end
  end
end
