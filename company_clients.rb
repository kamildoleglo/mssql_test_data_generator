require_relative "numbers.rb"

require_relative "connection.rb"

client = Conn.new.client

people_ids = client.execute("SELECT client_id FROM people WHERE DATEDIFF(YEAR, birthdate, GETDATE()) > 18")
people_ids = people_ids.map{|i| i["client_id"]}

companies_ids = client.execute("SELECT client_id FROM companies")
companies_ids = companies_ids.map{|i| i["client_id"]}

company_clients_ids = people_ids.sample((people_ids.length*0.7).round)

companies = companies_ids.length
puts "Generating company employees..."
company_clients_ids.each_with_index do |person_id, index|
    client.execute("INSERT INTO company_clients (employee_client_id, fk_company_client_id) VALUES (#{person_id}, #{companies_ids[index % companies]} )")
end

client.close