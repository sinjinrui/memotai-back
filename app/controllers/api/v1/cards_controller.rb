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

    if params[:archived] == "true"
      cards = cards.archived.order(:archived_at)
    else
      cards = cards.active.order(:position)
    end
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

  def destroy
    card = current_user.cards.find(params[:id])
    card.destroy
    head :no_content
  end

  def archive
    card = current_user.cards.active.find(params[:id])
    card.update!(
      archived_at: Time.current
    )

    render json: card
  end

  def restore
    card = current_user.cards.archived.find(params[:id])

    card.update!(
      archived_at: nil
    )

    card.insert_at(1)

    render json: card
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
