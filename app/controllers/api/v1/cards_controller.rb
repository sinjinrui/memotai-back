class Api::V1::CardsController < ApplicationController
  before_action :authorize_request, except: [ :share_cards ]

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

    cursor_card = user_cards.find_by(id: params[:last_id]) rescue nil
    if params[:archived] == "true"
      cards = if cursor_card.present?
        user_cards.archived .where(
          "archived_at < ? OR (archived_at = ? AND id < ?)",
          cursor_card.archived_at,
          cursor_card.archived_at,
          cursor_card.id
        ).order(archived_at: :desc, id: :desc)
      else
        user_cards.archived.order(archived_at: :desc)
      end
    else
      cards = if cursor_card.present?
        user_cards.active.where(position: (cursor_card.position + 1)..Float::INFINITY).order(:position)
      else
        user_cards.active.order(:position)
      end
    end

    cards = cards.limit(11)

    has_more = cards.length > 10
    cards = cards.first(10)

    render json: {
      cards: cards,
      has_more: has_more
    }
  end

  def share_cards
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    decoded = JsonWebToken.decode(token)
    current_user = User.registered.find_by(id: decoded[:user_id]) if decoded

    cards = Card
      .where(user_id: User.registered.ids)
      .where(character_code: params[:character_code], enemy_code: params[:enemy_code])
      .order(Arel.sql("
        (
          LOG(LEAST(copy_count, 50) + 1) * 4
          + 100 / (EXTRACT(EPOCH FROM (NOW() - created_at)) / 3600 + 2)
          + (CASE WHEN copy_count = 0 THEN 1 ELSE 0 END)
          + RANDOM() * 2
        ) DESC
      "))
      .limit(10)

    cards = cards.where.not(user_id: current_user.id) if current_user

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

  def copy
    origin_card = Card.find(params[:id])
    new_card = Card.new(
      text: origin_card.text,
      character_code: origin_card.character_code,
      enemy_code: origin_card.enemy_code,
      user_id: current_user.id
    )
    if new_card.save!
      new_card.insert_at(1)
      origin_card.update!(copy_count: origin_card.copy_count + 1) unless current_user.is_guest
    end
    head :no_content
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
