require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  describe "#reset" do
    let(:user) { create(:user, email_address: "coach@example.com") }
    let(:mail) { described_class.reset(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Reset your password")
      expect(mail.to).to eq([ "coach@example.com" ])
    end

    it "renders a link containing a valid password reset token" do
      link = mail.body.encoded[%r{http://\S+/passwords/(\S+)/edit}, 1]

      expect(link).to be_present
      expect(User.find_by_password_reset_token!(link)).to eq(user)
    end
  end
end
