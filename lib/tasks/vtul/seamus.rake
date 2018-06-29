# Based on: https://github.com/thomasfl/wordpress_import
require 'tasks/vtul/wordpress_parser'
require 'tasks/vtul/seamus_importer'
require 'json'

namespace :seamus do

  desc 'Extract SEAMUS XML - Authors. To run: bin/rake seamus:extract_authors["input.xml", "output.json"]'
  task :extract_authors, [:input_xml_file, :output_json_file] => :environment do |task, args|
    begin
      input_xml_file = args.input_xml_file
      output_json_file = args.output_json_file
      if args.input_xml_file.nil? || args.output_json_file.nil?
        raise ArgumentError.new("Valid input xml and output json files must be provided.")
      end

      puts "Attempting to read input xml file: " + input_xml_file

      content = ""
      open(input_xml_file) do |s| content = s.read end

      wp_authors = Array.new
      wp_author_profiles = Hash.new
      importer = SeamusImporter.new
      WordPress.parse_wp_authors(content) do | wp_author |
        wp_authors << wp_author
        wp_author_profiles[wp_author.login] = importer.scrape_user_profile(wp_author.login)
        sleep(5.seconds) # Wait before moving on to not hammer a site? 
      end

      wp_authors_file = File.new(output_json_file,'w+')
      wp_authors_file.puts JSON.pretty_generate(JSON.parse(wp_authors.to_json))
      puts "Output json file written to: "+output_json_file

      # TODO: Allow to pass in output file as parameter for the hash of scraped profiles
      #       For now, write to "output_json_file"+".scraped_profiles"
      wp_authors_file = File.new(output_json_file+".scraped_profiles",'w+')
      wp_authors_profile_file.puts JSON.pretty_generate(JSON.parse(wp_author_profiles.to_json))
      puts "Output json file of scraped profiles written to: "+output_json_file+".scraped_profiles"
    rescue ArgumentError => ae
      puts "Error: "+ae.message
      puts 'To run: bin/rake seamus:extract_authors["input.xml", "output.json"]'
    end
  end

  desc 'Import SEAMUS XML - Authors. To run: bin/rake seamus:import_authors["input.xml"]'
  task :import_authors, [:input_xml_file] => :environment do |task, args|
    begin
      input_xml_file = args.input_xml_file
      if args.input_xml_file.nil? 
        raise ArgumentError.new("Valid input xml file must be provided.")
      end

      puts "Attempting to read input xml file: " + input_xml_file

      content = ""
      open(input_xml_file) do |s| content = s.read end

      importer = SeamusImporter.new
      WordPress.parse_wp_authors(content) do | wp_author |
        importer.import_wp_author(wp_author)
      end

      puts "Import completed."
    rescue ArgumentError => ae
      puts "Error: "+ae.message
      puts 'To run: bin/rake seamus:import_authors["input.xml"]'
    end
  end

  desc 'Extract SEAMUS XML - Items. To run: bin/rake seamus:extract_items["input.xml","output.json"]'
  task :extract_items, [:input_xml_file, :output_json_file] => :environment do |task, args|
    begin
      input_xml_file = args.input_xml_file
      output_json_file = args.output_json_file
      if args.input_xml_file.nil? || args.output_json_file.nil?
        raise ArgumentError.new("Valid input xml and output json files must be provided.")
      end

      puts "Attempting to read input xml file: " + input_xml_file

      content = ""
      open(input_xml_file) do |s| content = s.read end

      items = Array.new
      WordPress.parse_items(content) do | item |
        items <<  item
      end

      items_file = File.new(output_json_file,'w+')
      items_file.puts JSON.pretty_generate(JSON.parse(items.to_json))
      puts "Output json file written to: "+output_json_file
    rescue ArgumentError => ae
      puts "Error: "+ae.message
      puts 'To run: bin/rake seamus:extract_items["input.xml", "output.json"]'
    end
  end

  desc 'Import SEAMUS XML - Items. Must be run AFTER import_authors. To run: bin/rake seamus:import_items["input.xml"]'
  task :import_items, [:input_xml_file] => :environment do |task, args|
    begin
      input_xml_file = args.input_xml_file
      if args.input_xml_file.nil?
        raise ArgumentError.new("Valid input xml file must be provided.")
      end

      puts "Attempting to read input xml file: " + input_xml_file

      content = ""
      open(input_xml_file) do |s| content = s.read end

      authors = Hash.new
      WordPress.parse_wp_authors(content) do | wp_author |
        authors[wp_author.login] = wp_author
      end

      importer = SeamusImporter.new
      WordPress.parse_items(content) do | item |
        owner = authors[item.owner]
        importer.import_item(item, owner)
      end

      puts "Import completed."
      ActiveFedora::Base.reindex_everything # TODO: Do I need this?
      puts "Index Updated."
    rescue ArgumentError => ae
      puts "Error: "+ae.message
      puts 'To run: bin/rake seamus:import_items["input.xml"]'
    end
  end
end
