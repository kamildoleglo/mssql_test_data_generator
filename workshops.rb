require_relative "numbers.rb"
require "csv"
require "date"
require_relative "connection.rb"
names_file = "src/workshop_names.csv"

client = Conn.new.client

names = CSV.read(names_file, {:encoding => 'UTF-8'})

delta = (Date.new(2017,12,31) - Date.new(2015,1,1))/72
start_date = Date.new(2015,1,1)
workshop_ids = []

puts "Generating workshops..."
names.each do |name|
    end_date = start_date + rand(1..4) 
    workshop_id = client.execute("INSERT INTO workshops (name, price, participants_limit) VALUES (N'#{client.escape(name.join(""))}', #{rand(50..200)}, #{rand(50..100).round(-1)})").insert
    workshop_ids << workshop_id
end

result = client.execute("SELECT id FROM conference_days")
conference_day_ids = result.map{|i| i["id"]}


conference_day_ids.each do |id|
    for i in 0..rand(2..4)
        start_time = (Number.time_rand Time.local(2010,1,1, "+14:00"), Time.local(2010,1,1, "+16:00")).strftime("%H:%M")
        end_time = (Number.time_rand Time.local(2010,1,1, "+17:00"), Time.local(2010,1,1, "+19:00")).strftime("%H:%M")  
        client.execute("INSERT INTO workshop_entities (start_time, end_time, fk_conference_day_id, fk_workshop_id) VALUES ('#{start_time}', '#{end_time}', #{id}, #{workshop_ids.sample})").insert
    end
end
