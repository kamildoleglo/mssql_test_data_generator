require_relative "numbers.rb"
require "csv"
require "date"
require_relative "connection.rb"
names_file = "src/conference_names.csv"

client = Conn.new.client

names = CSV.read(names_file, {:encoding => 'UTF-8'})

delta = (Date.new(2017,12,31) - Date.new(2015,1,1))/72
start_date = Date.new(2015,1,1)
puts "Generating conferences..."
names.each do |name|
    end_date = start_date + rand(1..4) 
    conference_id = client.execute("INSERT INTO conferences (name, start_date, end_date, participants_limit, base_price, student_discount) VALUES (N'#{client.escape(name.join(""))}', '#{start_date}', '#{end_date}', #{rand(150..300).round(-1)}, #{rand(100..300)*(end_date-start_date)}, #{rand.round(3)})").insert
    
    for j in 0..(end_date - start_date)
        start_time = (Number.time_rand Time.local(2010,1,1, "+07:00"), Time.local(2010,1,1, "+09:00")).strftime("%H:%M")
        end_time = (Number.time_rand Time.local(2010,1,1, "+11:00"), Time.local(2010,1,1, "+13:00")).strftime("%H:%M")
        client.execute("INSERT INTO conference_days (start_time, end_time, day_in_group, fk_conference_id) VALUES ('#{start_time}', '#{end_time}', #{j}, #{conference_id})").insert
    end

    k = 0
    l = rand(3)
    discount = rand(0.3..0.5)
    days_before = start_date - (start_date-rand(l*7..l*20))
    while k < l && discount > 0.0 && days_before > 0
        client.execute("INSERT INTO prices (base_price_discount, days_before, fk_conference_id) VALUES (#{discount.round(3)}, #{days_before}, #{conference_id})").insert
        k += 1
        discount = discount - (k*discount/l)
        days_before += (days_before + rand(2))/2 
    end
    start_date += delta
end


