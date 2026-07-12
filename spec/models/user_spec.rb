require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    expect(user.email_address).to eq("downcased@example.com")
  end

  it "requires a unique email_address" do
    create(:user, email_address: "taken@example.com")
    duplicate = build(:user, email_address: "taken@example.com")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email_address]).to be_present
  end

  it "requires a password" do
    user = build(:user, password: nil, password_confirmation: nil)

    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end

  it "requires the password confirmation to match when given" do
    user = build(:user, password: "password123", password_confirmation: "does-not-match")

    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).to be_present
  end

  it "authenticates with the correct password" do
    user = create(:user, password: "password123", password_confirmation: "password123")

    expect(user.authenticate("password123")).to eq(user)
    expect(user.authenticate("wrong-password")).to eq(false)
  end

  it "destroys associated sessions when destroyed" do
    user = create(:user)
    user.sessions.create!

    expect { user.destroy }.to change { Session.count }.by(-1)
  end
end
