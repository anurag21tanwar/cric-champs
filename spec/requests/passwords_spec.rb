require "rails_helper"

RSpec.describe "Passwords", type: :request do
  include ActiveJob::TestHelper

  let!(:user) { create(:user) }

  describe "GET /passwords/new" do
    it "is accessible without authentication" do
      get new_password_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /passwords" do
    it "enqueues a reset email for a known user and redirects to sign in" do
      expect {
        post passwords_path, params: { email_address: user.email_address }
      }.to have_enqueued_mail(PasswordsMailer, :reset).with(user)

      expect(response).to redirect_to(new_session_path)
    end

    it "does not enqueue an email for an unknown user, but redirects the same way" do
      expect {
        post passwords_path, params: { email_address: "missing-user@example.com" }
      }.not_to have_enqueued_mail(PasswordsMailer, :reset)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /passwords/:token/edit" do
    it "is accessible with a valid reset token" do
      get edit_password_path(user.password_reset_token)

      expect(response).to have_http_status(:ok)
    end

    it "redirects with an invalid token" do
      get edit_password_path("invalid-token")

      expect(response).to redirect_to(new_password_path)
    end
  end

  describe "PUT /passwords/:token" do
    it "updates the password when confirmation matches" do
      expect {
        put password_path(user.password_reset_token), params: { password: "new-password123", password_confirmation: "new-password123" }
      }.to change { user.reload.password_digest }

      expect(response).to redirect_to(new_session_path)
    end

    it "does not update the password when confirmation does not match" do
      token = user.password_reset_token

      expect {
        put password_path(token), params: { password: "new-password123", password_confirmation: "does-not-match" }
      }.not_to change { user.reload.password_digest }

      expect(response).to redirect_to(edit_password_path(token))
    end
  end
end
