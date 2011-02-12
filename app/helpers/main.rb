class Main
  helpers do
    def logged_in?
      return false unless request.cookies.has_key?("user_challenge") && request.cookies.has_key?("user")
      user = $cached_users[request.cookies['user']]
      if user.nil?
        user = User.get(request.cookies['user'])
        $cached_users[user.id] = user unless user.nil?
      end
      
      return false if user.nil?
      return false unless user.challenges && user.challenges.include?(request.cookies['user_challenge'])

      @user = user
      return true
    end
  end
end
