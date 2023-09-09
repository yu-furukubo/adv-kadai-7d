# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :ensure_correct_user, only: [:update, :edit, :destroy]

  def show
    @book = Book.find(params[:id])
    @books = Book.all
    @book_new = Book.new
    @book_comment = BookComment.new
    @book_tags = @book.tags
  end

  def index
    if params[:latest]
      @books = Book.order(created_at: :desc)
    elsif params[:oldest]
      @books = Book.order(created_at: :asc)
    elsif params[:star_count]
      @books = Book.order(star: :desc)
    else
      @books = Book.all
    end
    @book = Book.new
    @tag_lists = Tag.all
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    tag_list = params[:book][:name].split(',')
    if @book.save
      @book.save_tags(tag_list)
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render "index"
    end
  end

  def edit
    @book = Book.find(params[:id])
    @tag_list = @book.tags.pluck(:name).join(',')
  end

  def update
    @book = Book.find(params[:id])
    tag_list=params[:book][:name].split(',')
    if @book.update(book_params)
      @book.save_tags(tag_list)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  def search_tag
    @tag_list = Tag.all
    if params[:tag_id] != nil
      @tag = Tag.find(params[:tag_id])
    elsif params[:book_tag_id] != nil
      @tag = Tag.find(params[:book_tag_id])
    end
    @books = @tag.books
  end

  private
    def book_params
      params.require(:book).permit(:title, :body, :star)
    end

    def ensure_correct_user
      @book = Book.find(params[:id])
      unless @book.user_id == current_user.id
        redirect_to books_path
      end
    end

end
