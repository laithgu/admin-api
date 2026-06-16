class Comment < ApplicationRecord
  belongs_to :movie

  validates :content, presence: true, length: { maximum: 1000 }
  validates :author,  presence: true
end
