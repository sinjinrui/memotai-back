class Api::V1::TagsController < ApplicationController
  before_action :authorize_request

  def index
    tags = Tag.where(user_id: [ nil, current_user.id ])

    tags_json = tags.map do |tag|
      { id: tag.id, name: tag.name, is_default: tag.user_id.nil? }
    end

    render json: {
      tags: tags_json
    }, status: 200
  rescue => e
    render json: { message: "一時的なエラーが発生しました。時間をおいてお試しください。" }, status: :unprocessable_entity
  end
end
