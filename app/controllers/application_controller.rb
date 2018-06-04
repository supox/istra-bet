class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  def validate_admin
    if not current_user.try(:admin?)
      render file: "#{Rails.root.to_s}/public/401.html", status: :unauthorized
    end
  end
end
