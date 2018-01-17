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
end


client.close