require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, password: "password123", password_confirmation: "password123") }

  describe "GET /session/new" do
    it "is accessible without authentication" do
      get new_session_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "signs the user in and redirects to the root path" do
        post session_path, params: { email_address: user.email_address, password: "password123" }

        expect(response).to redirect_to(root_path)
        expect(cookies[:session_id]).to be_present
      end
    end

    context "with invalid credentials" do
      it "redirects back to the sign in page without a session" do
        post session_path, params: { email_address: user.email_address, password: "wrong-password" }

        expect(response).to redirect_to(new_session_path)
        expect(cookies[:session_id]).to be_blank
      end
    end
  end

  describe "DELETE /session" do
    it "signs the user out and redirects to the sign in page" do
      sign_in_as(user)

      delete session_path

      expect(response).to redirect_to(new_session_path)
      expect(cookies[:session_id]).to be_blank
    end
  end
end
