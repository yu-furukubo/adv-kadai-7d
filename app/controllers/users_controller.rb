# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :ensure_correct_user, only: [:update, :edit]
  before_action :ensure_guest_user, only: [:edit]

  def show
    @user = User.find(params[:id])
    @books = @user.books
    @book = Book.new
    @tag_lists = Tag.all
  end

  def index
    @users = User.all
    @book = Book.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "You have updated user successfully."
    else
      render "edit"
    end
  end

  def follow_users
    @user = User.find(params[:id])
    @users = @user.following_users
  end

  def follower_users
    @user = User.find(params[:id])
    @users = @user.followed_users
  end

  private
    def user_params
      params.require(:user).permit(:name, :introduction, :profile_image)
    end

    def book_params
      params.require(:book).permit(:title, :body, :user_id)
    end

    def ensure_correct_user
      @user = User.find(params[:id])
      unless @user == current_user
        redirect_to user_path(current_user)
      end
    end

    def ensure_guest_user
      @user = User.find(params[:id])
      if @user.guest_user?
        redirect_to user_path(current_user), notice: "ゲストユーザーはプロフィール編集画面へ遷移できません。"
      end
    end
end
