class ApplicationMailer < ActionMailer::Base
  default from: 'supox0@walla.co.il',
          reply_to: 'no-reply@betibam.herokuapp.com'
  layout 'mailer'
end
