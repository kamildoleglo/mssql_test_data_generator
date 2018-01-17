require "date"
require "time"
require_relative "connection.rb"

client = Conn.new.client

conference_days = client.execute("SELECT cd.id, c.participants_limit, c.start_date FROM conferences c RIGHT JOIN conference_days cd ON c.id = cd.fk_conference_id")
conference_days.map{|i| i}

conference_day_bookings = client.execute("SELECT b.id, b.fk_conference_day_id, b.reserved_seats FROM conference_day_bookings b ")
conference_day_bookings.each{}
#client.execute("SELECT b.id, b.fk_conference_day_id, b.reserved_seats, p.fk_participant_client_id FROM conference_day_bookings b INNER JOIN conference_day_participants p ON b.id = p.fk_conference_day_booking_id")
#people = people.map{|i| i["client_id"]}

puts "Generating workshop bookings..."
conference_day_bookings.each do |booking|
    next if rand(100) > 40
    participants = client.execute("SELECT p.id FROM conference_day_participants p WHERE fk_conference_day_booking_id = #{booking['id']}")
    participants = participants.map{|i| i["id"]}
    next if participants.length < 2
    participants_i = 0
    workshops = client.execute("
    SELECT we.id, we.start_time, we.end_time, w.participants_limit, ISNULL(SUM(wb.reserved_seats), 0) AS reserved, w.participants_limit - ISNULL(SUM(wb.reserved_seats),0) AS seats_left 
    FROM workshop_entities we 
    LEFT JOIN workshop_bookings wb ON we.id = wb.fk_workshop_entity_id 
    INNER JOIN workshops w ON w.id = we.fk_workshop_id 
    WHERE we.fk_conference_day_id = #{booking['fk_conference_day_id']}
    GROUP BY we.id, we.start_time, we.end_time, w.participants_limit
    ")
    #workshops.each {}
    n_of_w = workshops.count
    next if n_of_w < 1
    to_reserve = rand(1...participants.length)
    per_w = (to_reserve / n_of_w).round
    next if per_w < 1

    workshops.each do |w|
        to_res = [per_w, w['seats_left']].min
        w_booking_id = client.execute("INSERT INTO workshop_bookings (fk_workshop_entity_id, fk_conference_day_booking_id, reserved_seats) VALUES (#{w['id']}, #{booking['id']}, #{to_res})").insert
        to_res.times do
            client.execute("INSERT INTO workshop_participants (fk_workshop_booking_id, fk_conference_day_participant_id) VALUES (#{w_booking_id}, #{participants[participants_i]})").insert
            participants_i += 1
        end
    end

        
=begin

    workshop_booking_id = client.execute("INSERT INTO ")
    
    parts = rand(3..8)
    #puts "parts: " + parts.to_s + " for id: " + conf["id"].to_s
    companies_local = Array.new(companies)
    people_local = Array.new(people)
    limit = conf["participants_limit"]
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
        payment_date = booking_date + rand(0..(conf["start_date"] - booking_date)) 
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
=end
end


