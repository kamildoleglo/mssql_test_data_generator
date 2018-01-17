require 'tiny_tds'  

class Conn < TinyTds::Client
    attr_reader :client
    @client

    def initialize
        @client = TinyTds::Client.new(username: 'kdoleglo', password: 'hJZG6qgR',  
        host: 'mssql.iisg.agh.edu.pl', port: 1433,  
        database: 'kdoleglo_a')

        @client.execute("SET ANSI_DEFAULTS ON").do
        @client.execute("SET QUOTED_IDENTIFIER ON").do
        @client.execute("SET CURSOR_CLOSE_ON_COMMIT OFF").do
        @client.execute("SET IMPLICIT_TRANSACTIONS OFF").do
        @client.execute("SET TEXTSIZE 2147483647").do
        @client.execute("SET CONCAT_NULL_YIELDS_NULL ON").do
    end
end
