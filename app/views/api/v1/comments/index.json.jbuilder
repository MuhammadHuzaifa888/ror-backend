json.comments do
  json.(@comments) do |comment|
    json.id comment.id
    json.description comment.description
    json.parent_id  comment.parent_id
    json.comment_time  comment.created_at
    json.user comment.user.username
    json.user_image comment.user.profile_image.attached? ? comment.user.profile_image.blob.url : ''
    json.child_comment comment.comments do |child_comment|
      json.id child_comment.id
      json.description child_comment.description
      json.parent_id  child_comment.parent_id
      json.child_comment_time  child_comment.created_at
      json.user child_comment.user.username
      json.user_image child_comment.user.profile_image.attached? ? child_comment.user.profile_image.blob.url : ''
    end
  end
end