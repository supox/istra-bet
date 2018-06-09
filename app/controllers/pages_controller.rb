class PagesController < ApplicationController
  def home
    @tournaments = Tournament.all
    if current_user.try(:admin?)
      @users = User.confirmed.all
    end
  end
end
