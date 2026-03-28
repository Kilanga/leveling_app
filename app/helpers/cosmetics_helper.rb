module CosmeticsHelper
  # Retourne CSS pour envelopper un pseudo avec son cadre de profil
  def frame_wrapper_classes(frame)
    return "profile-frame-none" unless frame

    normalized_name = normalize_cosmetic_name(frame.name)

    case normalized_name
    when /standard/
      "profile-frame-standard"
    when /electrique/
      "profile-frame-electrique"
    when /legendaire/
      "profile-frame-legendaire"
    when /gyrophare|police/
      "profile-frame-gyrophare"
    else
      "profile-frame-none"
    end
  end

  # Retourne le nom du cadre pour l'affichage
  def frame_display_name(frame)
    frame&.name || "Sans cadre"
  end

  # Retourne CSS pour la barre XP selon le thème
  def xp_theme_classes(xp_theme)
    return "xp-theme-standard" unless xp_theme

    normalized_name = normalize_cosmetic_name(xp_theme.name)

    case normalized_name
    when /standard/
      "xp-theme-standard"
    when /samourai/
      "xp-theme-samourai"
    when /neon/
      "xp-theme-neon"
    when /legendaire/
      "xp-theme-legendaire"
    else
      "xp-theme-standard"
    end
  end

  # Retourne le nom du thème pour l'affichage
  def xp_theme_display_name(xp_theme)
    xp_theme&.name || "Thème Standard"
  end

  # Retourne CSS pour la carte de visite
  def profile_card_classes(card)
    return "profile-card-none" unless card

    normalized_name = normalize_cosmetic_name(card.name)

    case normalized_name
    when /standard/
      "profile-card-standard"
    when /bleu nuit/
      "profile-card-bleu-nuit"
    when /incendie/
      "profile-card-incendie"
    when /royale/
      "profile-card-royale"
    else
      "profile-card-none"
    end
  end

  # Retourne le nom de la carte pour l'affichage
  def profile_card_display_name(card)
    card&.name || "Pas de carte"
  end

  # Retourne le texte personnalisé de la carte (tronqué à 100 chars.)
  def profile_card_text(user)
    user.profile_card_custom_text.to_s.strip[0..99]
  end

  private

  def normalize_cosmetic_name(name)
    I18n.transliterate(name.to_s.downcase)
  end
end
