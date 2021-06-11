class SettingsController < ApplicationController

  def unsubscribe
    user_id = Rails.application.message_verifier(:unsubscribe).verify(params[:id])
    @user = User.find(user_id)
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = @user.subscription ? 'Subscribed' : 'Subscription Cancelled' 
      redirect_to root_url
    else
      flash[:alert] = 'There was a problem'
      render :unsubscribe
    end
  end

  private
  def user_params
    params.require(:user).permit(:subscription)
  end

end
