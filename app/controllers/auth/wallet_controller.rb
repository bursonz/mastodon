# Manage wallet
# method for nonce_generation, signature_validation, wallet_login
class Auth::WalletController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :load_wallet, only: [:nonce, :authorize]
  before_action :load_wallet, only: [:nonce]


  def nonce
    response = [nonce: @wallet.nonce, address: @wallet.address] if prepare
    render json: response
  end

  # def authorize
  #   if warden.authenticate! :wallet_auth
  #     # login
  #     redirect_to root
  #   elsif @wallet&.validate_signature wallet_params[:signature]
  #     # signup
  #     redirect_to new_user_registration_path :wallet_address => @wallet.address
  #   else
  #     render json: nil
  #   end
  # end


  def load_wallet
    @wallet = Wallet.find_by(address: wallet_address) if valid?
  end

  def prepare
    if @wallet.blank?
      @wallet = Wallet.create(wallet_params)
    end
    @wallet.persisted?
  end

  def valid?
    params[:address].present?
  end

  def wallet_params
    params[:address] = params[:address]&.downcase
    params.permit(:address, :signature)
  end

  def wallet_address
    params.permit(:address)[:address]&.downcase
  end

end
