require "date"
require "time"
require_relative "connection.rb"

client = Conn.new.client

puts "Generating conference bookings..."
conference_days = client.execute("SELECT cd.id, c.participants_limit, c.start_date FROM conferences c RIGHT JOIN conference_days cd ON c.id = cd.fk_conference_id")
conference_days.map{|i| i}
companies = client.execute("SELECT client_id FROM companies")
companies = companies.map{|i| i["client_id"]}
companies.compact!
people = client.execute("SELECT client_id FROM people WHERE client_id NOT IN (SELECT employee_client_id FROM company_clients)")
people = people.map{|i| i["client_id"]}

conference_days.each do |conf|
    parts = rand(3..8)
    #puts "parts: " + parts.to_s + " for id: " + conf["id"].to_s
    companies_local = Array.new(companies)
    people_local = Array.new(people)
    limit = conf["participants_limit"] > 200 ? 200 : conf["participants_limit"] 
    reserved = 0
    to_reserve_for_company_clients = ((limit / parts).round * (parts-2)) 
    to_reserve_for_individual = (limit / parts).round
    
    while reserved < to_reserve_for_company_clients && companies_local.length > 0
        #puts "reserved: " + reserved.to_s + " to_reserve: " + to_reserve_for_company_clients.to_s + " comp.len: " + companies_local.length.to_s
        comp = companies_local.delete_at(rand(companies_local.length-1))
        next if comp == nil
        employees = client.execute("SELECT employee_client_id FROM company_clients WHERE fk_company_client_id = #{comp}")
        next if employees.count < 1
        employees = employees.map{|i| i["employee_client_id"]}
        to_reserve = (employees.length * 0.8).round
        if(limit - reserved < to_reserve )
            to_reserve = limit - reserved
        end
        if to_reserve < 1 
            break 
        end
        booking_date = conf["start_date"] - rand(8..40)
        payment_date = booking_date + rand(1..(conf["start_date"] - booking_date)) 
        booking_date = Time.parse(booking_date.to_s) + rand(86400) 
        payment_date = Time.parse(payment_date.to_s) + rand(86400)
        booking_date = booking_date.strftime("%Y-%m-%d %H:%M:%S")
        payment_date = payment_date.strftime("%Y-%m-%d %H:%M:%S")
        
        booking_id = client.execute("INSERT INTO conference_day_bookings (fk_client_id, booking_date, payment_date, reserved_seats, fk_conference_day_id) VALUES (#{comp}, '#{booking_date}', '#{payment_date}', #{to_reserve}, #{conf['id']})").insert
        for j in 0..to_reserve-1
            client.execute("INSERT INTO conference_day_participants (fk_conference_day_booking_id, fk_participant_client_id) VALUES (#{booking_id}, #{employees[j]})").insert
        end
        #puts "afterfor"
        reserved += to_reserve
    end
    #puts "afterwhile"
    reserved_ind = 0
    while (limit-reserved-1) > 0 && to_reserve_for_individual > reserved_ind
        person = people_local.delete_at(rand(people_local.length-1))
        next if person.nil?
        booking_date = conf["start_date"] - rand(8..40)
        payment_date = booking_date + rand(0..(conf["start_date"] - booking_date)) 
        booking_date = Time.parse(booking_date.to_s) + rand(86400) 
        payment_date = Time.parse(payment_date.to_s) + rand(86400)
        booking_date = booking_date.strftime("%Y-%m-%d %H:%M:%S")
        payment_date = payment_date.strftime("%Y-%m-%d %H:%M:%S")
        
        booking_id = client.execute("INSERT INTO conference_day_bookings (fk_client_id, booking_date, payment_date, fk_conference_day_id) VALUES (#{person}, '#{booking_date}', '#{payment_date}', #{conf['id']})").insert
        client.execute("INSERT INTO conference_day_participants (fk_conference_day_booking_id, fk_participant_client_id) VALUES (#{booking_id}, #{person})").insert
        reserved += 1
        reserved_ind += 1
    end
    #puts "afterdo"
end

client.close