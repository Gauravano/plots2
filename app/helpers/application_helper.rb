module ApplicationHelper
  # returns true if user is logged in and has any of the roles given, as ['admin','moderator']
  def logged_in_as(roles)
    if current_user
      has_valid_role = false
      roles.each do |role|
        has_valid_role = true if current_user.role == role
      end
      has_valid_role
    else
      false
    end
  end

  def emojify(content)
    if content.present?
      content.to_str.gsub(/:([\w+-]+):(?![^\[]*\])/) do |match|
        if emoji = Emoji.find_by_alias(Regexp.last_match(1))
          if emoji.raw
            emoji.raw
          else
            %(<img class="emoji" alt="#{Regexp.last_match(1)}" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
          end
        else
          match
        end
      end
    end
  end

  def emoji_names_list
    emojis = []
    image_map = {}
    Emoji.all.each do |e|
      next unless e.raw
      val = ":#{e.name}:"
      emojis << { value: val, text: e.name }
      image_map[e.name] = e.raw
    end
    { emojis: emojis, image_map: image_map }
  end

  def emoji_info
    emoji_names = ["thumbs-up", "thumbs-down", "laugh",
                   "hooray", "confused", "heart"]
    emoji_image_map = {
      "thumbs-up" => "https://assets-cdn.github.com/images/icons/emoji/unicode/1f44d.png",
      "thumbs-down" => "https://assets-cdn.github.com/images/icons/emoji/unicode/1f44e.png",
      "laugh" => "https://assets-cdn.github.com/images/icons/emoji/unicode/1f604.png",
      "hooray" => "https://assets-cdn.github.com/images/icons/emoji/unicode/1f389.png",
      "confused" => "https://assets-cdn.github.com/images/icons/emoji/unicode/1f615.png",
      "heart" => "https://assets-cdn.github.com/images/icons/emoji/unicode/2764.png"
    }
    [emoji_names, emoji_image_map]
  end

  def feature(title)
    features = Node.where(type: 'feature', title: title)
    if !features.empty?
      return features.last.body.to_s.html_safe
    else
      ''
    end
  end

  def feature_node(title)
    features = Node.where(type: 'feature', title: title)
    if !features.empty?
      return features.last
    else
      ''
    end
  end

  def locale_name_pairs
    I18n.available_locales.map do |locale|
      [I18n.t('language', locale: locale), locale]
    end
  end

  def insert_extras(body)
    body = NodeShared.nodes_grid(body)
    body = NodeShared.notes_thumbnail_grid(body)
    body = NodeShared.notes_grid(body)
    body = NodeShared.questions_grid(body)
    body = NodeShared.activities_grid(body)
    body = NodeShared.upgrades_grid(body)
    body = NodeShared.notes_map(body)
    body = NodeShared.notes_map_by_tag(body)
    body = NodeShared.people_map(body)
    body = NodeShared.people_grid(body, @current_user || nil) # <= to allow testing of insert_extras
    body = NodeShared.graph_grid(body)
    body = NodeShared.wikis_grid(body)
    body
  end

  # we should move this to the Node model:
  def render_map(lat, lon)
    render partial: 'map/leaflet', locals: { lat: lat, lon: lon }
  end

  # we should move this to the Comment model:
  # replaces inline title suggestion(e.g: {New Title}) with the required link to change the title
  def title_suggestion(comment)
    comment.body.gsub(/\[propose:title\](.*?)\[\/propose\]/) do
      a = ActionController::Base.new
      is_creator = current_user == Node.find(comment.nid).author
      title = Regexp.last_match(1)
      output = a.render_to_string(template: "notes/_title_suggestion",
                                  layout:   false,
                                  locals:   {
                                    user: comment.user.name,
                                    nid: comment.nid,
                                    title: title,
                                    is_creator: is_creator
                                  })
      output
    end
  end

  def filtered_comment_body(comment_body)
    if contain_trimmed_body?(comment_body)
      return comment_body.split(Comment::COMMENT_FILTER).first
    end
    comment_body
  end

  def contain_trimmed_body?(comment_body)
    comment_body.include?(Comment::COMMENT_FILTER)
  end

  def trimmed_body(comment_body)
    comment_body.split(Comment::COMMENT_FILTER).second
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|

      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}".to_sym] = h_v
        end
      else
        h[k] = v
      end
    end

    # I18n.backend.translations[:en] provides us all the English translations but in nested hash form so this function is used
    # to flatten the hash so that we can extract the key from the value
  end

  def translation(key, options = {})
    str = I18n.backend.translations[:en]
    translated_string = t(key, options)
    if translated_string.length > 3
    %(<span>#{translated_string} <a href="https://www.transifex.com/publiclab/publiclaborg/translate/#de/$?q=text%3A#{translated_string}">
          <i data-toggle="tooltip" data-placement="top" title="Needs translation? Click to help translate this text." style="position:relative; right:2px; color:#bbb;" class="fa fa-globe"></i></a>
       </span>)
    else
      translated_string
    end


    # This translation method would take the place of default translate helper <%= t('') %> provided by the rails
    # We would be using the translate helper for translating the key but will pass it in our HTML span
  end

  def value_to_key(value, options = {})
    flattened_hash = flatten_hash(I18n.backend.translations[:en])
    key = flattened_hash.invert[value]

    # Here, we accepted value from the view, model or controller and found key using that value.
    # The key is necessity because it's common in all the locales
  end
end
