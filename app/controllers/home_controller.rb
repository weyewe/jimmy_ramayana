class HomeController < ApplicationController
  def index
  end
  
  def awesome_image
    render :layout => false  
  end
  
end
