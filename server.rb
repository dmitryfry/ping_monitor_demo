require 'rubygems'
require 'net/ping'
require 'active_record'
require 'highline/import'
require 'pry'
require_relative "lib/advanced_ping"

ActiveRecord::Base.establish_connection(YAML::load(File.open('./config/database.yml')))
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))

class Host < ActiveRecord::Base
end

class Monotiring

  def initialize

    @valid_ip_regex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
    @valid_host_regex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"

  end

  def start
    loop do
      Ping.new.make_ping(Host.all)
    end
  end

  def add
    host = Host.new
    print 'enter valid ip adress or hostname: '
    host.name = gets.chomp
    host.save
  end

  def delete
    hosts = Host.all
    hosts.each {|host| puts "Host ID: #{host.id}, Host Name: #{host.name}"}
    print 'enter host id to delete: '
    enter = gets.chomp
    if hosts.exists?(enter)
      hosts.delete(enter)
    else
      puts "ID not present"
    end
  end

  def statistic
    Stats.new.statistics_method
  end
end

monitoring = Monotiring.new

begin
  puts
  loop do
    choose do |menu|
      menu.prompt = "Please select what to do: "
      menu.choice(:Start_Monitoring_Daemon) { monitoring.start() }
      menu.choice(:Add_Host) { monitoring.add() }
      menu.choice(:Delete_Host) { monitoring.delete() }
      menu.choice(:Statistic) { monitoring.statistic() }
      menu.choice(:Exit, "Exit program.") { exit }
    end
  end
end


































# class Server
#
#   attr_reader :options
#
#   def initialize(options)
#     @options = options
#   end
#
#   def run!
#     while true
#       puts "Doing some work"
#       sleep(2)
#     end
#   end
#
# end
