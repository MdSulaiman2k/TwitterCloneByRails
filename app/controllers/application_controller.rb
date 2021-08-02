class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :ensureTokenAuthentication

  NotAuthorized = Class.new(StandardError)

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_error_page(status: 404, text: "Not found")
  end

  rescue_from ApplicationController::NotAuthorized do |exception|
    render_error_page(status: 401, text: "unAuthorized")
  end

  private

  def render_error_page(status:, text:, template: "errors/routing")
    respond_to do |format|
      format.json { render json: { errors: [message: "#{status} #{text}"] }, status: status }
      format.xml { render xml: { errors: [message: "#{status} #{text}"] }, status: status }
    end
  end

  def ensureTokenAuthentication
    pattern = /^Bearer /
    header = request.headers["Authorization"]
    header = header.gsub(pattern, "") if header && header.match(pattern)
    user = User.find_by(userToken: header)
    if user.nil?
      raise ApplicationController::NotAuthorized
    end
    user
  end
end
