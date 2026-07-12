require "rails_helper"

RSpec.describe "Authentication flow", type: :request do
  it "lets a visitor sign up, land authenticated, sign out, and sign back in" do
    get root_path
    expect(response.body).to include("Sign in")
    expect(response.body).to include("Sign up")

    post registration_path, params: {
      user: {
        email_address: "player@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("player@example.com")

    delete session_path
    expect(response).to redirect_to(new_session_path)
    follow_redirect!
    expect(response.body).not_to include("player@example.com")

    post session_path, params: { email_address: "player@example.com", password: "password123" }
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("player@example.com")
  end
end
