namespace :scrape do
  desc "Scrape info from Botanical Interests"
  task botanical: :environment do
    require "net/http"

    list = "botanical_interests_vegetable_list.json"

    vegetables = if File.exist?(list)
      json = JSON.parse(File.read(list))

      puts "Found a list of #{json.count} vegetables cached, using that!"

      json
    else
      page_range = (1..30)
      vegetables = page_range.to_a.each_with_object(Set.new) do |number, memo|
        puts "Fetching vegetable list from Botanical Interests, page #{number}..."
        uri = URI "https://www.botanicalinterests.com/category/view-all-vegetables/#{number}"
        response = Net::HTTP.get_response uri
        doc = Nokogiri::HTML response.body

        if doc.css("#prodlist li").any?
          doc.css(".product").each do |vegetable|
            veggie_name = vegetable.css("h2").text.squish
            veggie_url = vegetable.css(".content > a").first["href"]

            memo << { "name" => veggie_name, "url" => veggie_url }
          end
        else
          puts "Oops, looks like page #{number} is empty, so we went through all pages!"
          break memo
        end
      end

      require "json"

      File.open(list, "wb") do |file|
        puts "Saving vegetable list to #{list}..."
        file << JSON.pretty_generate(vegetables)
      end

      vegetables
    end

    puts "Found #{vegetables.length} vegetables!"

    binding.irb

    File.open("#{Time.current.strftime("%Y-%m-%d")}-botanical_interests_individual_plants.json", "wb") do |file|
      vegetables.reject { |v| v['name'].include?("Sow and Grow Guide") }.each do |veggie|
        puts "Fetching data for #{veggie['name']} ..."

        uri = URI "https://www.botanicalinterests.com#{veggie['url']}"
        puts uri
        response = Net::HTTP.get uri

        binding.irb if response.empty?

        doc = Nokogiri::HTML response

        tabs = [
          1, # variety info
          2, # sowing info
          3  # growing info
        ]

        properties = tabs.map do |tab|
          doc.css(".tab_data_container .tab-pane:nth-child(#{tab}) > p").each_with_object({}) do |p, memo|
            print "."

            next if p.content.squish.empty?

            key = p.content.split(":").first.parameterize
            value = p.content.split(":").last.squish

            memo[key] = value
          end
        end.each_with_object({ "name" => veggie['name'], "source_url" => uri }) do |arr, memo|
          arr.each do |k,v|
            memo[k] = v
          end
        end
        print "\n"

        if properties.empty?
          puts "Couldn't find any sowing info for #{veggie['name']} at #{uri}"
          next
        end

        puts "Found sowing info for #{properties["name"]}."

        output = JSON.pretty_generate(properties)

        file << "#{output},\n"
      end
    end
  end

  desc "Load stored JSON import of Botanical Interests data"
  task load: :environment do
    file = Dir.glob("*botanical_interests.json").last
    hash = eval File.read(file)
    json = hash.to_json

    File.open("#{Time.current.strftime("%Y-%m-%d")}-botanical_interests_fixed.json", "wb") do |file|
      file << json
    end
  end
end
