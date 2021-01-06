#!/usr/bin/env ruby

if ARGV.length != 1
    puts "usage: #{__FILE__} <usernames file>"
    exit
end

user_file = ARGV[0]

File.open(user_file).each do |line|
  if (line[/^\s*#/])
    next  
  end

  line = line.chomp
  
  name, login = line.split(":")
  #login = email.split("@")[0]
  firstname, lastname = name.split(" ")
   
  puts "#{login}:#{login}"    
  puts "#{login}:#{lastname}"    
  puts "#{login}:#{lastname.downcase if lastname}"    
  puts "#{login}:#{firstname}"    
  puts "#{login}:#{firstname.downcase}"  
  puts "#{login}:#{firstname.downcase}.#{lastname.downcase if lastname}"  
  puts "#{login}:#{firstname}.#{lastname}"  
  puts "#{login}:#{firstname.downcase}#{lastname.downcase if lastname}"  
  puts "#{login}:#{firstname}#{lastname}"  
  puts "#{login}:#{lastname.downcase if lastname}.#{firstname.downcase}"  
  puts "#{login}:#{lastname}.#{firstname}"  
  puts "#{login}:#{lastname.downcase if lastname}#{firstname.downcase}"  
  puts "#{login}:#{lastname}#{firstname}"  
  puts "#{login}:#{firstname}#{lastname[0] if lastname}"  
  puts "#{login}:#{firstname}#{lastname[0].downcase if lastname}"  
  puts "#{login}:#{firstname.downcase}#{lastname[0].downcase if lastname}"  
  puts "#{login}:#{firstname.downcase}.#{lastname[0].downcase if lastname}"  
  puts "#{login}:#{firstname.downcase}.#{lastname[0] if lastname}"  
  puts "#{login}:#{firstname}.#{lastname[0].downcase if lastname}"
  puts "#{login}:#{firstname}.#{lastname[0] if lastname}"  
  puts "#{login}:#{lastname}#{firstname[0]}"  if lastname
  puts "#{login}:#{lastname}.#{firstname[0]}" if lastname
  puts "#{login}:#{lastname}_#{firstname[0]}" if lastname  
  puts "#{login}:#{lastname.downcase if lastname}.#{firstname[0].downcase}" if lastname
  puts "#{login}:#{lastname.downcase if lastname}_#{firstname[0].downcase}" if lastname
  
end