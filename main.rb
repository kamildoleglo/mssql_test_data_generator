require_relative "clients.rb"


client = Conn.new.client
client.execute("EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'").do
client.close
require_relative "students.rb"
require_relative "companies.rb"
require_relative "company_clients.rb"
require_relative "conferences.rb"
require_relative "workshops.rb"
require_relative "conference_bookings.rb"
require_relative "workshop_bookings.rb"

client = Conn.new.client
client.execute("EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all'").do
client.close


