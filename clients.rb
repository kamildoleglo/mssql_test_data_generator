require_relative "numbers.rb"
require "csv"
require_relative "connection.rb"
female_names_file = "src/female_names.csv"
male_names_file = "src/male_names.csv"


client = Conn.new.client
begin
    client.execute("INSERT INTO countries (country) VALUES ('Poland')").insert
rescue TinyTds::Error => e
        
end

female_names = CSV.read(female_names_file, {:headers => true, :col_sep => ';', :encoding => 'WINDOWS-1250:UTF-8'})
male_names = CSV.read(male_names_file, {:headers => true, :col_sep => ';', :encoding => 'WINDOWS-1250:UTF-8'})

names = female_names

puts "Generating clients..."
2.times do
    for i in 0...names.length do
        street = client.execute("SELECT id FROM streets WHERE street LIKE '%#{names[i]['[street]']}%'")
        if street.each[0].nil?
            street_id = client.execute("INSERT INTO streets VALUES ('#{names[i]['[street]']}')").insert
        else
            street_id = street.each[0]["id"]
        end
        street.cancel
        country = client.execute("SELECT id FROM countries WHERE country LIKE '%Poland%'")
        country_id = country.each[0]["id"]
        country.cancel

        city = client.execute("SELECT id FROM cities WHERE city LIKE '%#{names[i]['[city]']}%' AND region LIKE '%#{names[i]['[region]']}%'")
        if city.each[0].nil?
            city_id = client.execute("INSERT INTO cities (city, region) VALUES ('#{names[i]['[city]']})', '#{names[i]['[region]']}')").insert
        else
            city_id = city.each[0]["id"]
        end
        street.cancel
        client_id = client.execute("INSERT INTO clients (phone, apartment, building, fk_street_id, fk_city_id, fk_country_id, zip_code) VALUES ('#{names[i]['[phone]']}', '#{Number.apartment}', '#{Number.building}', #{street_id}, #{city_id}, #{country_id}, '#{names[i]['[zip]']}')").insert
        client.execute("INSERT INTO people (client_id, first_name, surname, birthdate) VALUES (#{client_id}, '#{client.escape(names[i]['[name]'])}', '#{client.escape(names[i]['[surname]'])}', '#{ Date.strptime(names[i]['[birthdate]'], "%d.%m.%Y")}' )").insert
    end

    names = male_names
end   

client.close