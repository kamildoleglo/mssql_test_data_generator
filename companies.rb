require_relative "numbers.rb"
require "csv"
require_relative "connection.rb"
names_file = "src/company_names.csv"
additional_file = "src/company_additional.csv"


client = Conn.new.client

additional = CSV.read(additional_file, {:headers => true, :col_sep => ';', :encoding => 'WINDOWS-1250:UTF-8'}) 
names = CSV.read(names_file)
puts "Generating companies..."
for i in 0...([names.length, additional.length].min) do
    street = client.execute("SELECT id FROM streets WHERE street LIKE '%#{additional[i]['[street]']}%'")
    if street.each[0].nil?
        street_id = client.execute("INSERT INTO streets VALUES ('#{additional[i]['[street]']}')").insert
    else
        street_id = street.each[0]["id"]
    end
    street.cancel
    country = client.execute("SELECT id FROM countries WHERE country LIKE '%Poland%'")
    country_id = country.each[0]["id"]
    country.cancel

    city = client.execute("SELECT id FROM cities WHERE city LIKE '%#{additional[i]['[city]']}%' AND region LIKE '%#{additional[i]['[region]']}%'")
    if city.each[0].nil?
        city_id = client.execute("INSERT INTO cities (city, region) VALUES ('#{additional[i]['[city]']})', '#{additional[i]['[region]']}')").insert
    else
        city_id = city.each[0]["id"]
    end
    street.cancel
    client_id = client.execute("INSERT INTO clients (phone, apartment, building, fk_street_id, fk_city_id, fk_country_id, zip_code) VALUES ('#{additional[i]['[phone]']}', '#{Number.apartment}', '#{Number.building}', #{street_id}, #{city_id}, #{country_id}, '#{additional[i]['[zip]']}')").insert
    client.execute("INSERT INTO companies (client_id, name, TIN) VALUES (#{client_id}, '#{client.escape(names.sample.join(""))}', '#{additional[i]['[tin]']}' )").insert
end

client.close