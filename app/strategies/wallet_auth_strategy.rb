class WalletAuthStrategy < Warden::Strategies::Base

  def valid?
    params[:address].present?
  end

  def authenticate!
    wallet = Wallet.find_by(address: params[:address].downcase)
    if wallet&.bound? && wallet&.validate_signature(params[:signature])
      session[:wallet_address] = wallet.address
      user = User.find_by(id: wallet.user_id)
      if user
        success!(user)
      else
        fail!('Wallet auth failed')
      end
    end
  end

end
