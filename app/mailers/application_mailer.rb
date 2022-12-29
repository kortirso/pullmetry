# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app/views/mailers')

  default from: 'from@example.com'
  layout 'mailer'
end
