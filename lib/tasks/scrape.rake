namespace :scrape do
  desc "Scrape info from Botanical Interests"
  task botanical: :environment do
    require "net/http"

    page_range = (1..10)
    vegetables = page_range.to_a.each_with_object(Set.new) do |number, memo|
      puts "Fetching vegetable list from Botanical Interests, page #{number}..."
      uri = URI "https://www.botanicalinterests.com/category/view-all-vegetables/#{number}"
      response = Net::HTTP.get uri
      doc = Nokogiri::HTML response
      doc.css(".product h2").map { |e| e.content.squish }.each { |e| memo << e }
    end

    puts "Found #{vegetables.length} vegetables!"

    data = vegetables.each_with_object({}) do |veggie_name, memo|
      puts "Fetching data for #{veggie_name} ..."
      parameterized_name = veggie_name
      nixed = %w[ ' / ( )]
      replaced = { "#" => "X", " " => "-", "&" => "and", "ñ" => "n" }
      nixed.each { |n| parameterized_name = parameterized_name.gsub(n, "") }
      replaced.each { |key, value| parameterized_name = parameterized_name.gsub(key, value) }

      uri = URI "https://www.botanicalinterests.com/product/#{parameterized_name}"
      puts uri
      response = Net::HTTP.get uri
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
      end.each_with_object({}) do |arr, memo|
        arr.each do |k,v|
          memo[k] = v
        end
      end

      pp properties

      memo[properties["botanical-name"]] = properties
    end

    File.open("#{Time.current.strftime("%Y-%m-%d")}-botanical_interests.json", "wb") do |file|
      file << data.to_json
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
