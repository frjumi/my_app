module UsersHelper
  # Аватар: загруженный файл или Gravatar по email
  def avatar_for(user, size: 80)
    style = "width:#{size}px;height:#{size}px;object-fit:cover;"

    if user.avatar.attached?
      image_tag user.avatar, alt: user.name, class: 'avatar-img', style: style
    else
      gravatar_for(user, size: size)
    end
  end

  def gravatar_for(user, size: 80)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: 'gravatar avatar-img', style: "width:#{size}px;height:#{size}px;object-fit:cover;")
  end
end
