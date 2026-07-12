module SessionHelpers
  def sign_in_as(user)
    session = user.sessions.create!
    cookie_jar = ActionDispatch::TestRequest.create.cookie_jar
    cookie_jar.signed[:session_id] = session.id
    cookies["session_id"] = cookie_jar["session_id"]
    session
  end
end

RSpec.configure do |config|
  config.include SessionHelpers, type: :request
end
