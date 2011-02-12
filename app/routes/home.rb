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
end
