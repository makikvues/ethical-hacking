#!/usr/bin/env ruby

if ARGV.length != 1
    puts "usage: #{__FILE__} <users file>"
    exit
end

user_file = ARGV[0]

File.open(user_file).each do |line|
    if (line[/^\s*#/])
        next  
    end
    line = line.chop
    
	firstname,lastname = line.split(" ") if line
	
	firstname = firstname.downcase	
	lastname = lastname.downcase if lastname
  
	first = firstname[0]
	last = lastname[0] if lastname
  
    puts "#{firstname}" 
    puts "#{lastname}"  if lastname
    
    puts "#{firstname}#{lastname}"	if lastname
    puts "#{firstname}.#{lastname}"	if lastname
    puts "#{firstname}_#{lastname}"	if lastname
    
    puts "#{lastname}#{firstname}"	if lastname
    puts "#{lastname}.#{firstname}"	if lastname
    puts "#{lastname}_#{firstname}"	if lastname
    
    puts "#{firstname}#{last}"	if lastname
    puts "#{firstname}.#{last}"	if lastname
    puts "#{firstname}_#{last}"	if lastname
    
    puts "#{lastname}#{first}"	if lastname
    puts "#{lastname}.#{first}"	if lastname
    puts "#{lastname}_#{first}"	if lastname
    
    puts "#{first}#{lastname}"	if lastname
    puts "#{first}.#{lastname}"	if lastname
    puts "#{first}_#{lastname}"	if lastname
    
    puts "#{last}#{firstname}"	if lastname
    puts "#{last}.#{firstname}"	if lastname
    puts "#{last}_#{firstname}"	if lastname
  
end