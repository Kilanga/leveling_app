class PurchasesController < ApplicationController
  before_action :authenticate_user!

  def new
    @coins_prices = [
      { label: "100 pièces", amount: 5, coins: 100 },
      { label: "500 pièces", amount: 20, coins: 500 },
      { label: "1000 pièces", amount: 35, coins: 1000 }
    ]

    @boosts = [
      { label: "Boost XP x2 (1 jour)", amount: 10, duration: 1.day },
      { label: "Boost XP x2 (1 semaine)", amount: 50, duration: 7.days }
    ]

    @shop_items = ShopItem.where.not(item_type: "currency")

  end

  def create
    item = ShopItem.find(params[:shop_item_id])

    if item.price_coins.present? && current_user.coins >= item.price_coins
      current_user.decrement!(:coins, item.price_coins)
      current_user.user_items.create!(shop_item: item)
      redirect_to new_purchase_path, notice: "Objet acheté avec succès !"
    elsif item.price_euros.present?
      stripe_session = Stripe::Checkout::Session.create(
        payment_method_types: ["card"],
        line_items: [{
          price_data: {
            currency: "eur",
            product_data: { name: item.name },
            unit_amount: item.price_euros * 100
          },
          quantity: 1
        }],
        mode: "payment",
        success_url: success_purchases_url,
        cancel_url: cancel_purchases_url
      )
      session[:shop_item_id] = item.id
      redirect_to stripe_session.url, allow_other_host: true
    else
      redirect_to new_purchase_path, alert: "Achat impossible."
    end
  end

  def success
    if session[:shop_item_id]
      item = ShopItem.find(session[:shop_item_id])
      current_user.user_items.create!(shop_item: item)
      session.delete(:shop_item_id)
    end
    redirect_to root_path, notice: "Achat réussi !"
  end

  def cancel
    redirect_to new_purchase_path, alert: "Paiement annulé."
  end
end
