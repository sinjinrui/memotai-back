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
  user_cards = current_user.cards.where(
    character_code: params[:character_code],
    enemy_code: params[:enemy_code]
  )

  if params[:archived] == "true"
    cards = user_cards.archived.order(archived_at: :desc)
  else
    cursor_card = user_cards.find_by(id: params[:last_id]) rescue nil
    cards = if cursor_card.present?
      user_cards.active.where(position: (cursor_card.position + 1)..Float::INFINITY).order(:position)
    else
      user_cards.active.order(:position)
    end
  end

  cards = cards.limit(10)

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
    card.update!(archived_at: Time.current)
    card.remove_from_list
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
