require "rails_helper"

RSpec.describe NotificationService do
  let(:twilio_client) { double("TwilioClientDouble") }
  let(:fake_callback_url) { "http://localhost/callback" }
  let(:sender_sms_phone_number) { described_class::TWILIO_TEST_SMS_NUMBER }
  let(:sender_whatsapp_phone_number) { described_class::TWILIO_TEST_WHATSAPP_NUMBER }

  subject(:notification_service) { NotificationService.new }
  let(:recipient_phone_number) { "8585858585" }
  let(:expected_sms_recipient_phone_number) { "+918585858585" }

  def stub_client
    allow(notification_service).to receive(:client).and_return(twilio_client)
  end

  describe "test mode vs production mode" do
    it "uses the test twilio creds by default in test environment" do
      twilio_test_account_sid = ENV.fetch("TWILIO_TEST_ACCOUNT_SID")
      twilio_test_auth_token = ENV.fetch("TWILIO_TEST_AUTH_TOKEN")
      expect(Twilio::REST::Client).to receive(:new).with(twilio_test_account_sid, twilio_test_auth_token).and_call_original
      expect(notification_service.client).to be_instance_of(Twilio::REST::Client)
      expect(notification_service.test_mode?).to be_truthy
    end

    it "uses the production twilio creds when SIMPLE_SERVER_ENV is production" do
      stub_const("SIMPLE_SERVER_ENV", "production")
      twilio_account_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
      twilio_auth_token = ENV.fetch("TWILIO_AUTH_TOKEN")
      expect(Twilio::REST::Client).to receive(:new).with(twilio_account_sid, twilio_auth_token).and_call_original
      expect(notification_service.client).to be_instance_of(Twilio::REST::Client)
      expect(notification_service.test_mode?).to be_falsey
    end
  end

  describe "specifying an SMS sender" do
    it "uses the provided SMS sender number in production" do
      stub_const("SIMPLE_SERVER_ENV", "production")
      notification_service = NotificationService.new(sms_sender: "1234567890")
      expect(notification_service.twilio_sender_sms_number).to eq("1234567890")
    end

    it "uses the test number in test environments" do
      notification_service = NotificationService.new(sms_sender: "1234567890")
      expect(notification_service.twilio_sender_sms_number).to eq(NotificationService::TWILIO_TEST_SMS_NUMBER)
    end

    it "uses the primary number when no explicit sender is specified" do
      expect(notification_service.twilio_sender_sms_number).to eq(ENV.fetch("TWILIO_PHONE_NUMBER"))
    end
  end

  describe "#send_sms" do
    it "correctly calls the Twilio API" do
      stub_client

      expect(twilio_client).to receive_message_chain("messages.create").with(
        from: sender_sms_phone_number,
        to: expected_sms_recipient_phone_number,
        status_callback: fake_callback_url,
        body: "test sms message"
      )

      notification_service.send_sms(recipient_phone_number, "test sms message", fake_callback_url)
    end

    it "raises a custom error on twilio error" do
      stub_client
      allow(twilio_client).to receive_message_chain("messages.create").and_raise(Twilio::REST::TwilioError)

      expect{
        notification_service.send_sms(recipient_phone_number, "test sms message", fake_callback_url)
      }.to raise_error(NotificationService::Error)
    end
  end

  describe "#send_whatsapp" do
    it "correctly calls the Twilio API" do
      stub_client

      expect(twilio_client).to receive_message_chain("messages.create").with(
        from: "whatsapp:#{sender_whatsapp_phone_number}",
        to: "whatsapp:#{expected_sms_recipient_phone_number}",
        status_callback: fake_callback_url,
        body: "test whatsapp message"
      )

      notification_service.send_whatsapp(recipient_phone_number, "test whatsapp message", fake_callback_url)
    end

    it "raises a custom error on twilio error" do
      stub_client
      allow(twilio_client).to receive_message_chain("messages.create").and_raise(Twilio::REST::TwilioError)

      expect{
        notification_service.send_whatsapp(recipient_phone_number, "test whatsapp message", fake_callback_url)
      }.to raise_error(NotificationService::Error)
    end
  end

  describe "#parse_phone_number" do
    before do
      @original_country = Rails.application.config.country
      Rails.application.config.country = {sms_country_code: "+880"}
    end

    after do
      Rails.application.config.country = @original_country
    end

    it "adds the correct country code" do
      stub_client

      expect(notification_service.parse_phone_number("98765 43210")).to eq("+8809876543210")
    end
  end
end
