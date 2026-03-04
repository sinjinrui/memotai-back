class Api::V1::CardsController < ApplicationController
  def create
    card = Card.new(card_params)
    card.user_id = current_user.id

    if card.save
      card.insert_at(1)
      render json: card
    else
      render json: { errors: card.errors }, status: :unprocessable_entity
    end
  end

  def update_position
    card = current_user.cards.find(params[:id])
    card.insert_at(params[:position].to_i)

    head :ok
  end

  def index
    cards = current_user.cards
              .where(character_code: params[:character_code],
                    enemy_code: params[:enemy_code])
              .order(:position)

    render json: cards
  end

  def update
    card = current_user.cards.find(params[:id])

    if card.update(card_params)
      render json: card, status: :ok
    else
      render json: { errors: card.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def card_params
    params.require(:card).permit(
      :text,
      :character_code,
      :enemy_code
    )
  end
end
