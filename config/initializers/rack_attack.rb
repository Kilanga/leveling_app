# Rate limiting basique sur les endpoints d'authentification.
class Rack::Attack
  ### Connexion : 5 tentatives / 20 s par IP, 10 / minute par email
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  throttle("logins/email", limit: 10, period: 1.minute) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email").to_s.downcase.presence
    end
  end

  ### Inscription : 5 comptes / heure par IP
  throttle("signups/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users" && req.post?
  end

  ### Réinitialisation de mot de passe : 5 / heure par IP
  throttle("password_resets/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "Content-Type" => "text/plain" }, [ "Trop de tentatives. Réessaie dans quelques instants.\n" ] ]
  end
end

Rack::Attack.enabled = !Rails.env.test?
