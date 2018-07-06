class SeamusImporter

  class UserProfile
    attr_accessor :login, :short_bio, :member_role, :member_website_link, 
                  :member_profile_img_src, :member_twitter_link, 
                  :member_facebook_link, :member_google_link,
                  :member_soundcloud_link
  end  

  def import_item(item, owner)
    printf "--- Importing: %s (%s, %s)\n", item.title, item.owner, item.url
    puts item.inspect
    # NOTE: There's no explicit distinction in the SEAMUS wordpress dump 
    #       indicating whether an item/article is a composition or performance.
    #       By default, a composition will always be created.
    #       If audio or video data exists, we'll create a performance and link
    #       to the composition.
    #       Currently in COMPEL, a performance needs to be linked to an 
    #       existing composition.
    composition = create_composition(item, owner)
    create_performance(item, composition) if is_performance?(item)
  end

  def import_wp_author(wp_author)
    printf "--- Importing: %s (%s, %s, %s)\n", wp_author.id, wp_author.login, wp_author.email, wp_author.display_name

    user = User.find_by({email: wp_author.email.downcase})
    if user.nil?
      begin
        puts "... User does not yet exist. Proceeding with creation..."

        profile = scrape_user_profile(wp_author.login)
        create_user(wp_author, profile)

        puts "... Waiting ..." # Wait before moving on to not hammer a site?
        sleep(5.seconds)
      rescue URI::InvalidURIError => iurie
        puts "!!!!! User creation failed " + iurie.message
      end
    else
      puts "... User exists. Skipping creation..."
    end
  end

  def scrape_user_profile(login)
    profile_url = "https://www.seamusonline.org/seamus-member/#{login.tr(" ", "-")}"
    puts "... Scraping SEAMUS profile page: "+profile_url

    seamus_profile = HTTParty.get(profile_url)
    profile_page ||= Nokogiri::HTML(seamus_profile)

    profile = UserProfile.new
    profile.short_bio = profile_page.css('.short-bio').children.map { |bio| bio.text }.compact.join(',')
    profile.member_role = profile_page.css('.member-role').children.map { |role| role.text }.compact.join(',')
    profile.member_website_link = get_first_class_href(profile_page, '.member-website-link')
    profile.member_profile_img_src = get_first_class_src(profile_page, '.member-profile-wrap')
    profile.member_twitter_link = get_first_class_href(profile_page, '.member-twitter-link')
    profile.member_facebook_link = get_first_class_href(profile_page, '.member-facebook-link')
    profile.member_google_link = get_first_class_href(profile_page, '.member-google-link')
    profile.member_soundcloud_link = get_first_class_href(profile_page, '.member-soundcloud-link')
    return profile
  end

  protected

    def is_performance?(item)
      clip = item.metadata.performance_clip
      recording = item.metadata.link_to_recording
      if (clip.nil? || clip.empty?) && (recording.nil? || recording.empty?)
        return false
      else
        return true
      end
    end

    def create_composition(item, owner)
      puts "... Creating Composition"
      composition = Composition.new
      composition.creator = [owner.email]
      composition.depositor = owner.email
      composition.date_created = [item.metadata.year_of_composition]
      composition.title = [item.title]
      composition.duration = item.metadata.duration
      composition.source = [item.metadata.link_to_score_resources]
      composition.subject = item.metadata.instrumentation
      composition.subject = ["(none)"] if composition.subject.empty?
      composition.description = [item.body, item.metadata.subtitle]

      # For now, all provided SEAMUS items appear to be public
      composition.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      composition.save!
      puts "... Composition Created Successfully." + composition.inspect
      composition
    end
  
    def create_performance(item, composition)
      puts "... Creating Performance"
      performance = Performance.new
      performance.creator = composition.creator
      performance.depositor = composition.depositor
      performance.composition_id = composition.id
      performance.title = [item.title]
      performance.date_created = [item.metadata.year_of_composition]
      performance.contributor = composition.creator
      performance.subject = item.metadata.instrumentation
      performance.subject = ["(none)"] if performance.subject.empty?
      performance.description = [item.body, item.metadata.subtitle]
      performance.duration = item.metadata.duration
      performance.related_url = performance_links(item)
  
      # For now, all provided SEAMUS items appear to be public
      performance.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      performance.save!
      puts "... Performance Created Successfully." + performance.inspect
      performance
    end

    def performance_links(item)
      links = []
      if !((item.metadata.link_to_recording.nil?) || (item.metadata.link_to_recording.empty?))
        links << item.metadata.link_to_recording
      end
      if !((item.metadata.performance_clip.nil?) || (item.metadata.performance_clip.empty?))
        links << item.metadata.performance_clip
      end
      return links
    end

    def get_first_class_src(page, class_name)
      page.css(class_name).css('img').first['src'] unless page.css(class_name).css('img').first.nil?
    end

    def get_first_class_href(page, class_name) 
      page.css(class_name).css('a').first['href'] unless page.css(class_name).css('a').first.nil?
    end

    def personal_statement(profile)
      if profile.member_role.empty?
        profile.short_bio.to_s
      else 
        (profile.member_role.to_s + ". " + profile.short_bio.to_s)
      end
    end

    def google_plus_handle(uri)
      # Google plus handles seem more complicated to parse.
      # Assumes that the uri is already known to be a google plus uri
      path_fragments = uri.path.split("/").reject{ |s| s.empty? }
      if path_fragments.size < 1
        return nil
      elsif path_fragments.first[0] == '+'
        return path_fragments.first[1..-1] #remove the '+'
      else
        return nil # unable to parse
      end
    end

    def handle(link)
      return link if link.nil?

      link_uri = URI(link)
      if (link_uri.host == "plus.google.com") || (link_uri.host == "google.com")
        return google_plus_handle(link_uri)
      else
        # The following seems to work for twitter and facebook.
        # Returns the first part of the path as the handle
        # Otherwise, returns nil
        return link_uri.path.split("/").reject{ |s| s.empty? }.first
      end
    end

    def create_user(wp_author, user_profile)
      puts "... Attempting to create new COMPEL user: " + wp_author.email

      user = User.new({email: wp_author.email})
      user.display_name = wp_author.display_name
      user.password = SecureRandom.uuid
      user.personal_statement = personal_statement(user_profile)
      user.twitter_handle = handle(user_profile.member_twitter_link)
      user.facebook_handle = handle(user_profile.member_facebook_link)
      user.googleplus_handle = handle(user_profile.member_google_link)
        
      if !( user_profile.member_website_link.nil? || user_profile.member_website_link.blank?)
        wlink = UserLink.find_or_create_by({link: user_profile.member_website_link})
        wlink.link = user_profile.member_website_link
        user.user_links << wlink
      end

      # TODO: Potentially add as new social media via LIBTD-1385
      # For now, add as website
      if !( user_profile.member_soundcloud_link.nil? || user_profile.member_soundcloud_link.blank?)
        slink = UserLink.find_or_create_by({link: user_profile.member_soundcloud_link})
        slink.link = user_profile.member_soundcloud_link
        user.user_links << slink
      end

      begin
        # Initially try to save without the profile image
        user.save!
        puts "... User imported to COMPEL: "+user.inspect

        upload_user_avatar(user, user_profile)
      rescue ActiveRecord::RecordInvalid => ri_error
        puts "!!!!! User creation failed: " + ri_error.message
      end

    end
 
    def upload_user_avatar(user, user_profile)
      if user_profile.member_profile_img_src == 'https://www.seamusonline.org/wp-content/uploads/2014/09/Circuit-Pattern-Yellow-485x485.jpg'
        puts "... User avatar is SEAMUS default. Avatar left blank."
        return
      end

      # Now, try to save the profile image url
      # If it fails, that's okay.
      # There are all sorts of reasons why this might fail:
      #   Image is larger than allowed by the AvatarValidator
      #   Image doesn't exist (404 error?), etc.
      user.remote_avatar_url = user_profile.member_profile_img_src
      begin
        user.save!
        puts "... User avatar uploaded to COMPEL."
      rescue ActiveRecord::RecordInvalid => ri_error
        puts "!!!!! User avatar upload failed: " + ri_error.message
      end 
    end
end
