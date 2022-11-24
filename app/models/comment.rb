class Comment < ApplicationRecord
  belongs_to :post, optional: true
  belongs_to :user, optional: true
  belongs_to :story, optional: true
  belongs_to :parent, class_name:  'Comment',optional: true
  has_many :comments,foreign_key: :parent_id
  has_many :likes,dependent: :destroy
end