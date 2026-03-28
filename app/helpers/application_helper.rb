module ApplicationHelper
	def page_meta_title
		custom_title = content_for(:title).to_s.strip
		return custom_title if custom_title.present?

		base = "Leveling"
		page = case "#{controller_path}##{action_name}"
		when "welcome#index"
			"Progression gamifiee"
		when "dashboard#index"
			"Accueil"
		when "quests#index"
			"Quetes"
		when "quests#show"
			"Detail quete"
		when "purchases#new"
			"Boutique"
		when "leaderboard#index"
			"Classement"
		when "users#show"
			"Profil"
		when "friends#index", "friends#search"
			"Amis"
		when "onboarding#show"
			"Onboarding"
		when "notifications#index"
			"Notifications"
		when "admin/analytics#index"
			"Analytics"
		when "devise/sessions#new"
			"Connexion"
		when "devise/registrations#new"
			"Inscription"
		when "devise/passwords#new"
			"Mot de passe oublie"
		else
			nil
		end

		page.present? ? "#{page} | #{base}" : base
	end

	def page_meta_description
		custom_description = content_for(:meta_description).to_s.strip
		return custom_description if custom_description.present?

		case "#{controller_path}##{action_name}"
		when "welcome#index"
			"Leveling transforme ta progression personnelle en jeu: quetes, ligues hebdo, streaks et defis entre amis."
		when "dashboard#index"
			"Suis ta progression, valide tes quetes et fais monter ton niveau sur Leveling."
		when "quests#index"
			"Explore les quetes disponibles et choisis celles qui font avancer ta progression."
		when "purchases#new"
			"Decouvre la boutique Leveling: packs, boosts et titres pour personnaliser ton profil."
		when "leaderboard#index"
			"Compare ta progression avec les autres joueurs sur le classement Leveling."
		when "users#show"
			"Consulte ton profil, equipe tes titres et suis ton evolution sur Leveling."
		when "friends#index", "friends#search"
			"Ajoute des amis, suis leur progression et avance ensemble sur Leveling."
		when "onboarding#show"
			"Configure tes priorites de progression et demarre rapidement sur Leveling."
		when "notifications#index"
			"Consulte tes rappels, activites sociales et alertes de progression sur Leveling."
		when "devise/sessions#new"
			"Connecte-toi a Leveling pour reprendre tes quetes et continuer ta progression."
		when "devise/registrations#new"
			"Cree ton compte Leveling et lance ta progression des aujourd'hui."
		else
			"Leveling: l'application de progression personnelle avec quetes, titres et classement."
		end
	end

	def user_avatar_image(user, width:, height:, css_class: "", alt: nil)
		alt_text = alt || "Avatar de #{user.pseudo}"

		if user.active_avatar_item&.image&.attached?
			image_tag(
				user.active_avatar_item.image.variant(resize: "#{width}x#{height}"),
				class: css_class,
				width: width,
				height: height,
				alt: alt_text
			)
		else
			image_tag(user.avatar, class: css_class, width: width, height: height, alt: alt_text)
		end
	end

def page_canonical_url
  return nil unless request.get?

  "#{request.base_url}#{request.path}"
end

def page_robots_content
  public_pages = %w[
    welcome#index
    pages#terms
    pages#privacy
    devise/sessions#new
    devise/registrations#new
    devise/passwords#new
  ]

  public_pages.include?("#{controller_path}##{action_name}") ? "index, follow" : "noindex, nofollow"
end

def page_og_image_url
  image_url("logo-leveling.svg")
end

def page_og_locale
  locale = I18n.locale.to_s
  locale == "fr" ? "fr_FR" : locale
end

def page_alternate_locale_urls
  return {} unless request.get?

  I18n.available_locales.each_with_object({}) do |locale, acc|
    query = request.query_parameters.merge(locale: locale.to_s)
    query_string = query.to_query
    acc[locale.to_s] = "#{request.base_url}#{request.path}#{query_string.present? ? "?#{query_string}" : ""}"
  end
end

def page_x_default_url
  return nil unless request.get?

  "#{request.base_url}#{request.path}"
end
end
