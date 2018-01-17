require_relative "numbers.rb"
require "csv"
require_relative "connection.rb"

client = Conn.new.client

people = client.execute("SELECT * FROM people")
take = people.do * 0.1
take = take.round.to_i
people.cancel

people = client.execute("SELECT client_id FROM people WHERE DATEDIFF(YEAR, birthdate, GETDATE()) < 26")
people_ids = people.to_a.sample(take)

people.cancel

puts "Generating students..."
people_ids.each do |id|
    begin
        no = Number.student_id
    end while client.execute("SELECT * FROM student_ids WHERE student_id_no = '#{no}' ").do > 0 
        
    client.execute("INSERT INTO student_ids (client_id, student_id_no) VALUES (#{id['client_id']}, '#{no}' )").insert
end

client.close