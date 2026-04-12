class Api::V1::ReportCardsController < ApplicationController
  before_action :authorize_request

  def create
    raise StandardError if current_user.is_guest
    card = Card.where.not(user_id: current_user).find_by(id: params[:id])
    reason = ReportCard.reason_text[params[:reason].to_sym]
    report_card = ReportCard.new(user_id: current_user.id, card_id: card.id, reason: reason)

    if report_card.save
      render json: { message: "通報を受け付けました" }, status: :ok
    else
      render json: { message: "エラーが発生しました。時間をおいてお試しください。" }, status: :unprocessable_entity
    end
  rescue => e
    render json: { message: "エラーが発生しました。時間をおいてお試しください。" }, status: :unprocessable_entity
  end
end
