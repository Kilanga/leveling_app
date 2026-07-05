# Création de sessions Stripe Checkout et redirection sécurisée.
# Partagé entre la boutique et le passe de saison.
module StripeCheckout
  extend ActiveSupport::Concern

  private

  def create_checkout_session(product_name, amount_eur, metadata = {})
    Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "eur",
          product_data: { name: product_name },
          unit_amount: amount_eur.to_i * 100
        },
        quantity: 1
      } ],
      mode: "payment",
      metadata: metadata.transform_values(&:to_s),
      success_url: success_purchases_url(session_id: "{CHECKOUT_SESSION_ID}"),
      cancel_url: cancel_purchases_url
    ).url
  end

  def safe_redirect_to_checkout(checkout_url)
    uri = URI.parse(checkout_url)
    allowed_hosts = [ "checkout.stripe.com", "pay.stripe.com" ]

    unless uri.is_a?(URI::HTTPS) && allowed_hosts.include?(uri.host)
      return redirect_to new_purchase_path, alert: I18n.t("flash.purchases.invalid_payment_url")
    end

    redirect_to uri.to_s, allow_other_host: true
  rescue URI::InvalidURIError
    redirect_to new_purchase_path, alert: I18n.t("flash.purchases.invalid_payment_url")
  end
end
