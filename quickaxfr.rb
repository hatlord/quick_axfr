#!/usr/bin/env ruby
#Domain transfer against all domains

require 'tty-command'
require 'logger'
require 'resolv'
require 'colorize'

domains = File.readlines(ARGV[0]).map(&:chomp &&:strip)

def command
  @log = Logger.new('debug.log')
  cmd  = TTY::Command.new(output: @log)
end

def nameservers(domains)
  @axfr_dom = []
  domains.each do |domain|
    Resolv::DNS.open do |dns|
      ns = dns.getresources domain, Resolv::DNS::Resource::IN::NS
      ns.map! { |m| [m.name.to_s, IPSocket::getaddress(m.name.to_s)] } rescue ns.map! { |m|  "" }
      ns.each { |n| @axfr_dom << [n[0], n[1], domain] }
    end
  end
end

def axfr(command)
  @axfr_dom.each do |dom|
    out, err = command.run!("dig axfr @#{dom[1]} #{dom[2]}")
      if out =~ /Transfer failed|communications error to/i
        puts "Zone transfer failed on server: #{dom[1]}/#{dom[0]} for domain #{dom[2]}".upcase.white.on_green
      elsif out =~ /XFR size/i
        puts "Zone transfer successful on server: #{dom[1]}/#{dom[0]} for domain #{dom[2]}".upcase.white.on_red
      elsif out =~ /connection timed out/i
        puts "Connection to DNS Servers Timed Out: #{dom[1]}/#{dom[0]} for domain #{dom[2]}".upcase.magenta.bold
      else
        puts "Unknown response on server: #{dom[1]}/#{dom[0]} for domain #{dom[2]} - Check debug.log".upcase.white.on_green
      end
  end    
end

command
nameservers(domains)
axfr(command)