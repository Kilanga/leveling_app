class PurchasesController < ApplicationController
  before_action :authenticate_user!
  def new
    @prices = {
      "100 pièces" => 5,
      "500 pièces" => 20,
      "Boost XP x2 (1 jour)" => 10,
      "Boost XP x2 (1 semaine)" => 50
    }
  end

  def create
    amount = params[:amount].to_i
    item_type = params[:item_type]

    if amount <= 0
      redirect_to new_purchase_path, alert: "Montant invalide."
      return
    end

    # Stocker les valeurs dans la session
    session[:item_type] = item_type
    session[:amount] = amount

    stripe_session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "eur",
          product_data: { name: item_type },
          unit_amount: amount * 100 # Stripe travaille en centimes
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: success_purchases_url,
      cancel_url: cancel_purchases_url
    )

    redirect_to stripe_session.url, allow_other_host: true
  end

  def success
    if session[:item_type] == "Boost XP x2 (1 jour)"
      current_user.update(boost_expires_at: 24.hours.from_now)
    elsif session[:item_type] == "Boost XP x2 (1 semaine)"
      current_user.update(boost_expires_at: 7.days.from_now)
    else
      current_user.increment!(:coins, session[:amount])
    end

    # Nettoyer la session après l'achat
    session.delete(:item_type)
    session.delete(:amount)

    redirect_to root_path, notice: "Achat réussi !"
  end

  def cancel
    flash[:alert] = "Paiement annulé."
    redirect_to new_purchase_path
  end
end
