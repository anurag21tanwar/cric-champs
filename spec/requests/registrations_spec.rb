require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /registration/new" do
    it "is accessible without authentication" do
      get new_registration_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /registration" do
    context "with valid params" do
      let(:params) do
        {
          user: {
            email_address: "new-coach@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates a new user" do
        expect { post registration_path, params: params }.to change(User, :count).by(1)
      end

      it "signs the user in and redirects to the root path" do
        post registration_path, params: params

        expect(response).to redirect_to(root_path)
        expect(cookies[:session_id]).to be_present
      end
    end

    context "with a duplicate email address" do
      it "does not create a user" do
        create(:user, email_address: "taken@example.com")
        params = { user: { email_address: "taken@example.com", password: "password123", password_confirmation: "password123" } }

        expect { post registration_path, params: params }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with mismatched password confirmation" do
      it "does not create a user" do
        params = { user: { email_address: "new-coach@example.com", password: "password123", password_confirmation: "nope" } }

        expect { post registration_path, params: params }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
