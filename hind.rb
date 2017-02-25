# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    hind.rb                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: Niko <niko.caron90@gmail.com>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2017/02/24 13:39:41 by Niko              #+#    #+#              #
#    Updated: 2017/02/24 23:34:42 by Niko             ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

require 'oauth2'

UID = ENV['HIND_UID']
SECRET = ENV['HIND_SECRET']
RESET = '0'.freeze
RED = '31'.freeze
GREEN = '32'.freeze
YELLOW = '33'.freeze

client = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
token = client.client_credentials.get_token

def display_colorized(text, color_code)
  print "\e[#{color_code}m#{text}\e[0m".rjust(25)
  puts "\e[0m\e[0m".rjust(25)
end

def display_location(info)
  puts 'USER'.ljust(20) + 'LOCATION'.rjust(16)

  info.each do |user|
    login = user[0]
    location = user[1]
    color = user[2]

    print login.ljust(20)
    display_colorized(location, color)
  end
end

if ARGV.size != 1
  display_colorized('Please try again with 1 argument.', RED)
  exit
end

file_loaded = ARGV[0]

login_location = []

print 'LOADING: '

File.open(file_loaded, 'r') do |file|
  file.each do |file_login|
    user_exists = 1
    endpoint = "/v2/locations/?user_id=#{file_login}&filter[active]=true"
    user_info = token.get(endpoint) rescue user_exists = 0

    if user_exists == 1
      if user_info.parsed.empty?
        login_location << [file_login.chomp, 'Not Available', YELLOW]
      else
        parsed_info = user_info.parsed[0]

        user_login = parsed_info['user']['login']
        user_location = parsed_info['host']

        login_location << [user_login, user_location, GREEN]
      end
    else
      login_location << [file_login.chomp, 'Not a User', RED]
    end
    print '.'
  end
  puts "\n" * 2
end

system('clear') || system('cls')

if login_location.empty?
  display_colorized('File is empty.'.ljust(25), RED)
else
  display_location(login_location)
end
