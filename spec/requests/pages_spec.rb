require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET / (landing page)" do
    it "is accessible without authentication" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    context "when signed out" do
      it "shows sign in and sign up links" do
        get root_path

        expect(response.body).to include("Sign in")
        expect(response.body).to include("Sign up")
      end
    end

    context "when signed in" do
      it "shows the current user's email address" do
        user = create(:user, email_address: "coach@example.com")
        sign_in_as(user)

        get root_path

        expect(response.body).to include("coach@example.com")
      end
    end
  end
end
