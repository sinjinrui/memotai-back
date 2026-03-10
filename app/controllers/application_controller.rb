class ApplicationController < ActionController::API
  before_action :verify_cloudfront

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    decoded = JsonWebToken.decode(token)
    @current_user = User.find(decoded[:user_id]) if decoded
    raise StandardError unless @current_user
  rescue
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  private

  def verify_cloudfront
    if Rails.env.production?
      expected = ENV["CLOUDFRONT_SECRET"]

      unless request.headers["CloudFront-Auth"] == expected
        head :forbidden
      end
    end
  end
end
