#!/usr/bin/env ruby -w

require 'io/console'

class KeyboardKeys < Hash
  
  attr_reader :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :q, :r, :s, :t, :u, :v, :w, :x, :y, :z, :n1, :n2, :n3, :n4, :n5, :n6, :n7, :n8, :n9, :n0, :other, :n_, :lowercase_chars

  def initialize()
    @a = {x: 0, y: 0}
    @b = {x: 1, y: 0}
    @c = {x: 2, y: 0}
    @d = {x: 3, y: 0}
    @e = {x: 4, y: 0}
    @f = {x: 5, y: 0}
    @g = {x: 0, y: 1}
    @h = {x: 1, y: 1}
    @i = {x: 2, y: 1}
    @j = {x: 3, y: 1}
    @k = {x: 4, y: 1}
    @l = {x: 5, y: 1}
    @m = {x: 0, y: 2}
    @n = {x: 1, y: 2}
    @o = {x: 2, y: 2}
    @p = {x: 3, y: 2}
    @q = {x: 4, y: 2}
    @r = {x: 5, y: 2}
    @s = {x: 0, y: 3}
    @t = {x: 1, y: 3}
    @u = {x: 2, y: 3}
    @v = {x: 3, y: 3}
    @w = {x: 4, y: 3}
    @x = {x: 5, y: 3}
    @y = {x: 0, y: 4}
    @z = {x: 1, y: 4}
    @n1 = {x: 2, y: 4}
    @n2 = {x: 3, y: 4}
    @n3 = {x: 4, y: 4}
    @n4 = {x: 5, y: 4}
    @n5 = {x: 0, y: 5}
    @n6 = {x: 1, y: 5}
    @n7 = {x: 2, y: 5}
    @n8 = {x: 3, y: 5}
    @n9 = {x: 4, y: 5}
    @n0 = {x: 5, y: 5}
    @other = {x: 6, y: 2}
    @lowercase_chars = {x: 6, y: 0}
    @n_ = {x: 4, y: 1}
  end

  def get_sym_by_str ch
    if is_i(ch)
      ch = "n" << ch
      return [send(ch.to_sym)]
    elsif is_c(ch)
      return [send(ch.to_sym)]
    else
      ch = "n" << ch
      return [@other, send(ch.to_sym), @lowercase_chars]
    end
    
  end

  def is_i ch
     !!(ch =~ /\A[-+]?[0-9]+\z/)
  end

  def is_c ch
     !!(ch =~ /\A[-+]?[a-z]+\z/)
  end

end

class KeyboardTraverser
 

  def initialize(roku_ip_address, username="", password="")
    @keyboard_keys = KeyboardKeys.new
    @current_key = @keyboard_keys.a
    @roku_ip_address = roku_ip_address
    
    @username = username
    @password = password

    show_single_key while(true)
  end

  def enter_username
    auto_key_press @username
  end

  def enter_password
    auto_key_press @password
  end

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
      #auto_key_press()
    when "\e[C"
      do_key_press "right"
    when "\e[D"
      do_key_press "left"
    when "\u0003"
      puts "Bye!"
      exit 0
    when "u"
      enter_username
    when "p"
      enter_password
    when "r"
      randomiser
    when /^.$/
      #puts "SINGLE CHAR HIT: #{c.inspect}"
      #to_key = @keyboard_keys.get_sym_by_str c
      #go_to_key to_key, @current_key
      #do_key_press "Select"
    else
      puts "SOMETHING ELSE: #{c.inspect}"
    end
  end

  def do_key_press(key)
    `curl -sd '' http://#{@roku_ip_address}:8060/keydown/#{key}`
    `curl -sd '' http://#{@roku_ip_address}:8060/keyup/#{key}`
  end
  
  public
  def auto_key_press(str)
    str.each_char {|c|
      to_keys = @keyboard_keys.get_sym_by_str c
      to_keys.each {|to_key|
        go_to_key to_key, @current_key
        do_key_press "Select"
        @current_key = to_key
      }
    }
    @current_key = @keyboard_keys.a
  end

  def go_to_key(to, from)
    x_dist = to[:x].to_i - from[:x].to_i
    y_dist = to[:y].to_i - from[:y].to_i
    move_x x_dist
    move_y y_dist  
  end

  def move_x dist
    i = 0
    if dist > 0
      while i < dist
          do_key_press_and_wait "right"
          i = i + 1
      end
    elsif dist < 0
      while i > dist
          do_key_press_and_wait "left"
          i = i - 1
      end
    end
  end 

  def move_y dist
    i = 0
    if dist > 0
      while i < dist
          do_key_press_and_wait "down"
          i = i + 1
      end
    elsif dist < 0
      while i > dist
          do_key_press_and_wait "up"
          i = i - 1
      end
    end
  end 

  def randomiser
    prng = Random.new
    while true
      n = prng.rand(0..6)
      case n
        when 0
          do_key_press "Select"
        when 1
          #do_key_press "up"
        when 2
          do_key_press "down"
        when 3
          do_key_press "right"
        when 4
          do_key_press "left"
        when 5
          #do_key_press "Back"
        when 6
          sleep 4
      end
    end
  end

  def do_key_press_and_wait direction
    do_key_press direction
  end
end

if ARGV.empty?
  puts "Please enter the IP address of your Roku"
elsif ARGV.length == 1
  roku_ip_address = ARGV[0]
  KeyboardTraverser.new roku_ip_address
elsif ARGV.length == 2
  roku_ip_address = ARGV[0]
  username = ARGV[1]
  KeyboardTraverser.new roku_ip_address, username
elsif ARGV.length == 3
  roku_ip_address = ARGV[0]
  username = ARGV[1]
  password = ARGV[2]
  KeyboardTraverser.new roku_ip_address, username, password
end

