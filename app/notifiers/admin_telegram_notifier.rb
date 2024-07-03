# frozen_string_literal: true

class AdminTelegramNotifier < CompanyNotifier
  self.driver = proc do |data|
    Pullmetry::Container['api.telegram.client'].send_message(
      bot_secret: Rails.application.credentials.dig(:telegram_oauth, Rails.env.to_sym, :bot_secret),
      chat_id: data[:chat_id],
      text: data[:body]
    )
  end

  def job_execution_report
    notification(
      chat_id: Rails.application.credentials[:reports_telegram_chat_id],
      body: "#{params[:job_name]} is run at #{DateTime.now}"
    )
  end

  def feedback_created
    notification(
      chat_id: Rails.application.credentials[:reports_telegram_chat_id],
      body: feedback_created_payload(params[:id])
    )
  end

  private

  def feedback_created_payload(id)
    feedback = Feedback.find_by(id: id)
    return '' unless feedback

    "User - #{feedback.user_id}\nFeedback created - #{feedback.title}\n#{feedback.description}"
  end
end
