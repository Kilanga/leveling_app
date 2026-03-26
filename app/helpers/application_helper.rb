module ApplicationHelper
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
end
