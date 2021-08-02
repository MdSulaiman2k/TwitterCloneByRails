class Api::V1::PostsController < ApplicationController
  def index
    @posts = Post.all
    respond_to do |format|
      format.json { render json: { data: @posts.as_json(only: [:id, :content, :user_id]) }, status: 200 }
      format.xml { render xml: { data: @posts.as_json(only: [:id, :content, :user_id]) }, status: 200 }
    end
  end

  def show
    @post = Post.find_by(id: params[:id])
    if (@post.nil?)
      raise ActiveRecord::RecordNotFound
    else
      respond_to do |format|
        format.json { render json: { data: @post.as_json(only: [:id, :content, :user_id]) }, status: 201 }
        format.xml { render xml: { data: @post.as_json(only: [:id, :content, :user_id]) }, status: 201 }
      end
    end
  end

  def create
    @post = Post.new(post_params)
    @user = ensureTokenAuthentication
    if (@user.id == @post.user_id and @post.save)
      respond_to do |format|
        format.json { render json: { data: @post.as_json(only: [:id, :content, :user_id]) }, status: 201 }
        format.xml { render xml: { data: @post.as_json(only: [:id, :content, :user_id]) }, status: 201 }
      end
    else
      raise ApplicationController::NotAuthorized
    end
  end

  def destroy
    @post = ensureTokenAuthentication.posts.find_by(id: params[:id])
    if @post.nil?
      raise ActiveRecord::RecordNotFound
    else
      @post.destroy
    end
    respond_to do |format|
      format.json { render json: { data: @post.as_json(only: [:id, :content, :user_id]) }, status: 202 }
      format.xml { render xml: { data: @post.as_json(only: [:id, :content, :user_id]) }, status: 202 }
    end
  end

  def destroy_all
    @post = ensureTokenAuthentication.posts.destroy_all
  end

  private

  def post_params
    params.require(:post).permit(:content, :user_id)
  end
end
