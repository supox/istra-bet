
RSpec.configure do |config|
  # For Devise > 4.1.1
  config.include Devise::Test::ControllerHelpers, :type => :controller
end
