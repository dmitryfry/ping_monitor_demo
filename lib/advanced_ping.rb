require 'net/ping'

module Enumerable

    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
    end

    def sample_variance
      m = self.mean
      sum = self.inject(0){|accum, i| accum +(i-m)**2 }
      sum/(self.length - 1).to_f
    end

    def standard_deviation
      return Math.sqrt(self.sample_variance)
    end

end

class Statistic < ActiveRecord::Base
end

class Ping
  def make_ping(hostparam)
    hostparam.each do |host|
      print "#{host.name}: "
      icmp = Net::Ping::ICMP.new(host.name)
      statistic = Statistic.new
    	if icmp.ping
    		ping_ms = (icmp.duration * 1000).round(3)
    		print "#{ping_ms} ms".ljust(13, " ")

    		ping_int = ping_ms.to_i/10
    		puts "".ljust(ping_int,".")
        statistic.host_id = host.id
        statistic.ping_ms = ping_ms
        statistic.save
    		sleep(1)
    	else
    		pingfails = 1
        statistic.host_id = host.id
        statistic.pingfails = pingfails
        statistic.save
    		puts "timeout"
    	end
    end
  end
end

class Stats

  def statistics_method
  # binding.pry
  # Statistic.where(:created_at => '2017-10-17 20:39:16 UTC'..'2017-10-17 20:39:17 UTC')
    puts "Enter start datetime"
    print "Example: 2017-10-17 20:39:16 UTC: "
    start_datetime = gets.chomp
    puts "Enter end datetime"
    print "Example: 2017-10-17 20:44:16 UTC: "
    end_datetime = gets.chomp

    @hosts = Host.all
    id_array = @hosts.ids

    id_array.map do |item_id|
      print "#{Host.find(item_id.to_i).name}: "
      statistic_grep = Statistic.where(host_id: item_id.to_i).where(:created_at => "#{start_datetime}".."#{end_datetime}")
      math_array = statistic_grep.select(:ping_ms).map {
        |item_ping| item_ping[:ping_ms].to_f
      }

      sum = 0
      repeat = statistic_grep.count
      statistic_grep.select(:pingfails).map { |item_fails|
        item_fails[:pingfails].to_i
      }.each { |a| sum+=a }

      pingfails = sum

      if repeat > 0
        loss = ((pingfails / repeat)*100)
        puts "#{repeat} packets transmitted, #{loss}% packet loss"
      end
      avg = math_array.mean.round(3) if math_array.mean != nil
      min = math_array.min.round(3) if math_array.min != nil
      max = math_array.max.round(3) if math_array.max != nil
      stdev = math_array.standard_deviation.round(3) if math_array.standard_deviation != nil


      puts "round-trip min/avg/max/stddev = #{min}/#{avg}/#{max}/#{stdev} ms"
    end
  end
end
