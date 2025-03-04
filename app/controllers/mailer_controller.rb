require "sib-api-v3-sdk"

class MailerController < ApplicationController
  def send_email
    SibApiV3Sdk.configure do |config|
      config.api_key["api-key"] = Rails.application.credentials.dig(:brevo, :smtp_key)
    end

    api_instance = SibApiV3Sdk::TransactionalEmailsApi.new

    sender = SibApiV3Sdk::Sender(email: Rails.application.credentials.dig(:brevo, :email))
    to = [ SibApiV3Sdk::SendSmtpEmailTo(email: Rails.application.credentials.dig(:brevo, :email)) ]
    subject = "Test Email"
    html_content = "<html><body><h1>Hello, World!</h1></body></html>"
    send_smtp_email = SibApiV3Sdk::SendSmtpEmail.new(sender: sender, to: to, subject: subject, html_content: html_content)

    begin
      result = api_instance.send_transac_email(send_smtp_email)
      puts result
    rescue SibApiV3Sdk::ApiError => e
      puts "Error while sending email: #{e}"
    end
  end
end
