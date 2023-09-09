# frozen_string_literal: true

class Book < ApplicationRecord
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  validates :title, presence:true
  validates :body, presence:true,length:{maximum:200}

  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  def self.looks(searches, words)
    if searches == "perfect_match"
      @book = Book.where("title LIKE?", "#{words}")
    else
      @book = Book.where("title LIKE?", "%#{words}%")
    end
  end

  def save_tags(book_tags)
    current_tags = self.tags.pluck(:name) unless self.tags.nil?
    old_tags = current_tags - book_tags
    new_tags = book_tags - current_tags

    old_tags.each do |old_name|
      self.tags.delete Tag.find_by(name:old_name)
    end

    new_tags.each do |new_name|
      tag = Tag.find_or_create_by(name:new_name)
      self.tags << tag
    end
  end


end
