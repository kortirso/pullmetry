# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  append_view_path Rails.root.join('app/views/mailers')

  include Emailbutler::Mailers::Helpers

  default from: 'from@pullkeeper.dev'
  layout 'mailer'
end
