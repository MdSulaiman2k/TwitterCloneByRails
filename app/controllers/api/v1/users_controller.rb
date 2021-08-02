class Api::V1::UsersController < ApplicationController
  skip_before_action :ensureTokenAuthentication, :only => [:create]

  def show
    @user = User.find_by(id: params[:id])
    if @user.nil?
      raise ActiveRecord::RecordNotFound
    end
    respond_to do |format|
      format.json { render json: { data: @user.as_json(only: [:name, :email]) }, status: 201 }
      format.xml { render xml: { data: @user.as_json(only: [:name, :email]) }, status: 201 }
    end
  end

  def index
    data = params[:limit].nil? ? 3 : Integer(params[:limit])
    page = params[:page].nil? ? 0 : Integer(params[:page])
    @users = User.all.limit(data).offset(data * page)
    respond_to do |format|
      format.json { render json: { data: @users.as_json(only: [:name, :email]) }, status: 201 }
      format.xml { render xml: { data: @users.as_json(only: [:name, :email]) }, status: 201 }
    end
  end

  def update
    @user = ensureTokenAuthentication
    user1 = User.find_by(id: params[:id])
    if (user1.nil? || @user.id != user1.id)
      raise ActiveRecord::RecordNotFound
    end
    @user.name = params[:name]
    @user.email = params[:email]
    if @user.save
      respond_to do |format|
        format.json { render json: { data: @user.as_json(only: [:name, :email]) }, status: 201 }
        format.xml { render xml: { data: @user.as_json(only: [:name, :email]) }, status: 201 }
      end
    else
      render_error_page(status: 401, text: @user.errors.full_messages.join(", "))
    end
  end

  def create
    @user = User.new(user_params)
    if (@user.save)
      respond_to do |format|
        format.json { render json: { data: @user.as_json(only: :userToken) }, status: 201 }
        format.xml { render xml: { data: @user.as_json(only: :userToken) }, status: 201 }
      end
    else
      raise ApplicationController::NotAuthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :userToken)
  end
end
