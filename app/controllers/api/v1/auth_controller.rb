# app/controllers/api/v1/auth_controller.rb
class Api::V1::AuthController < ApplicationController
  before_action :authorize_request, only: [ :logout, :migrate_account ]

  def signup
    user = User.new(user_params)

    if user.save
      access_token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
      refresh_token = JsonWebToken.encode({ user_id: user.id }, 30.days.from_now)

      user.update_columns(refresh_token: refresh_token)

      render json: {
        message: "User created",
        access_token: access_token,
        refresh_token: refresh_token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.registered.find_by(login_id: params[:login_id])

    if user&.authenticate(params[:password])
      access_token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
      refresh_token = JsonWebToken.encode({ user_id: user.id }, 30.days.from_now)

      user.update_columns(refresh_token: refresh_token)

      render json: {
        access_token: access_token,
        refresh_token: refresh_token
      }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def refresh
    refresh_token = params[:refresh_token]
    decoded = JsonWebToken.decode(refresh_token)

    return render json: { error: "Invalid token" }, status: :unauthorized unless decoded

    user = User.find_by(id: decoded[:user_id], refresh_token: refresh_token)
    return render json: { error: "Invalid token" }, status: :unauthorized unless user

    new_access_token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
    new_refresh_token = JsonWebToken.encode({ user_id: user.id }, 30.days.from_now)

    user.update_columns(refresh_token: new_refresh_token)

    render json: {
      access_token: new_access_token,
      refresh_token: new_refresh_token
    }, status: :ok
  end

  def guest_login
    user = User.new(is_guest: true, login_id: "guest_#{SecureRandom.hex(4)}", password: SecureRandom.hex(16))

    if user.save
      access_token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
      refresh_token = JsonWebToken.encode({ user_id: user.id }, 30.days.from_now)

      user.update_columns(refresh_token: refresh_token)

      render json: {
        message: "User created",
        access_token: access_token,
        refresh_token: refresh_token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def migrate_account
    user = User.new(user_params)

    if user.save
      ActiveRecord::Base.transaction do
        Card.where(user_id: current_user.id).update_all(user_id: user.id)
        current_user.destroy!
      end

      access_token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
      refresh_token = JsonWebToken.encode({ user_id: user.id }, 30.days.from_now)

      render json: {
        message: "User migrated",
        access_token: access_token,
        refresh_token: refresh_token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def logout
    user = User.find_by(id: current_user.id)
    if user.is_guest
      user.destroy!
    else
      user.update_columns(refresh_token: nil)
    end

    render json: { message: "Logged out" }
  end

  private

  def user_params
    params.permit(:login_id, :password, :password_confirmation)
  end
end
