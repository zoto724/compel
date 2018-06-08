namespace :compel do
  desc 'Create default roles.'
  task add_roles: :environment do
    ['admin', 'collection_admin', 'collection_user'].each do |role_name|
      Role.find_or_create_by({name: role_name})
      puts "Created role '#{role_name}'."
    end
  end

  desc 'Upgrade users to admins.'
  task upgrade_users: :environment do
    admin_role = Role.find_by({name: 'admin'})

    IO.foreach('admin_list.txt') do |email|
      email = email.strip
      user = User.find_by({email: email})

      if !user.nil?
        user.roles << admin_role
        user.roles = user.roles.uniq
        user.save!
        puts "#{email} upgraded."
      else
        puts "#{email} user does not exist in system."
      end
    end
  end

  desc 'Create COMPEL default CollectionType.'
  task create_default_collection_type: :environment do
    default_collection_type_settings={title: "Collection", machine_id: "DefaultCompelCollection", description: "Default COMPEL collection type"}
    if Hyrax::CollectionType.find_by(default_collection_type_settings)
      puts "Default COMPEL collection type already exists."
    else
      Hyrax::CollectionType.create(default_collection_type_settings)
      puts "Created default COMPEL collection type."
    end
  end
end
