class Wallet::AuthController < ApplicationController

  skip_before_action :require_functional!, unless: :whitelist_mode?
  before_action :load_wallet, only: [:nonce]

  def nonce
    response = [nonce: @wallet.nonce, address: @wallet.address] if prepare
    render json: response
  end

  def verify
    self.resource = warden.authenticate!(:wallet_authenticate)
    puts '************************************************'
    puts resource
    puts '************************************************'

    if resource.present?
      set_flash_message!(:notice, :signed_in)
      on_authentication_success(resource, :password) unless @on_authentication_success_called

    elsif true
      return redirect_to new_user_registration_path
    end

    respond_with resource, location: after_sign_in_path_for(resource)
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

  private

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
