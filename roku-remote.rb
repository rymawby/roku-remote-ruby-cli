#!/usr/bin/env ruby -w

require 'io/console'

# Reads keypresses from the user including 2 and 3 escape character sequences.
def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

# oringal case statement from:
# http://www.alecjacobson.com/weblog/?p=75
def show_single_key
  c = read_char

  case c
  when "\r"
    do_key_press "Select"
  when "\u007F"
    do_key_press "Back"
  when "\e[A"
    do_key_press "up"
  when "\e[B"
    do_key_press "down"
  when "\e[C"
    do_key_press "right"
  when "\e[D"
    do_key_press "left"
  when "\u0003"
    puts "Bye!"
    exit 0
  when /^.$/
    puts "SINGLE CHAR HIT: #{c.inspect}"
  else
    puts "SOMETHING ELSE: #{c.inspect}"
  end
end

def do_key_press(key)
  `curl -sd '' http://#{@roku_ip_address}:8060/keydown/#{key}`
  `curl -sd '' http://#{@roku_ip_address}:8060/keyup/#{key}`
end

if ARGV.length > 0
  @roku_ip_address = ARGV[0]
  show_single_key while(true)
else
  puts "Please enter the IP address of your Roku"
end
