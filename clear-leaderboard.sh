#!/bin/bash

# Title not directly translatable to shell scripts; this is generally done by the terminal emulator or can be set using escape sequences.
echo "Leaderboard Wiper - Working..."

# Check if Config.ini exists, if not create it and prompt the user to insert keys
if [ ! -f Config.ini ]; then
  echo 'PublicKey=""' > Config.ini
  echo 'SecretKey=""' >> Config.ini
  echo "Created Config.ini, Please insert your keys in there!"
  exec "$SHELL"
fi

# Read the PublicKey and SecretKey from Config.ini
while IFS='=' read -r key value; do
  case $key in
    'PublicKey') PublicKey=$value ;;
    'SecretKey') SecretKey=$value ;;
  esac
done < Config.ini

# Remove quotes and spaces from keys
PublicKey=$(echo $PublicKey | tr -d '"' | tr -d ' ')
SecretKey=$(echo $SecretKey | tr -d '"' | tr -d ' ')

# Check if PublicKey and SecretKey are valid
if [ -z "$PublicKey" ]; then
  echo "Invalid PublicKey!"
  exec "$SHELL"
fi
if [ -z "$SecretKey" ]; then
  echo "Invalid SecretKey!"
  exec "$SHELL"
fi

# Get leaderboard data
Users=$(curl -s "https://lcv2-server.danqzq.games/get?publicKey=$PublicKey" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8" \
  -H "Accept-Language: nl-NL,nl;q=0.8" \
  -H "Cache-Control: no-cache" \
  -H "Connection: keep-alive" \
  -H "Pragma: no-cache" \
  -H "Sec-Fetch-Dest: document" \
  -H "Sec-Fetch-Mode: navigate" \
  -H "Sec-Fetch-Site: cross-site" \
  -H "Sec-Fetch-User: ?1" \
  -H "Sec-GPC: 1" \
  -H "Upgrade-Insecure-Requests: 1" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36" \
  -H "sec-ch-ua: \"Brave\";v=\"125\", \"Chromium\";v=\"125\", \"Not.A/Brand\";v=\"24\"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: \"Windows\"")

if [ $? -ne 0 ]; then
  echo "Servers are not responding; check your internet connection if this reoccurs. Retrying..."
  exec "$SHELL"
fi

# Parse JSON and clean up the Users variable
Users=$(echo $Users | tr -d '[]{}"' | tr ',' '\n')

# Delete users
for entry in $Users; do
  IFS=':' read -r key value <<< "$entry"
  if [ "$key" == "username" ]; then
    Name=$value
    echo "Deleting $Name"

    # Send Packet 1
    curl -s "https://lcv2-server.danqzq.games/entry/delete" \
      -X "OPTIONS" \
      -H "Accept: */*" \
      -H "Accept-Language: nl-NL,nl;q=0.9,en-US;q=0.8,en;q=0.7" \
      -H "Access-Control-Request-Headers: sender" \
      -H "Access-Control-Request-Method: POST" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Origin: https://html-classic.itch.zone" \
      -H "Pragma: no-cache" \
      -H "Referer: https://html-classic.itch.zone/" \
      -H "Sec-Fetch-Dest: empty" \
      -H "Sec-Fetch-Mode: cors" \
      -H "Sec-Fetch-Site: cross-site" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
    if [ $? -ne 0 ]; then
      echo "Servers are not responding; check your internet connection if this reoccurs. Retrying..."
      exec "$SHELL"
    fi

    # Send Packet 2
    curl -s "https://lcv2-server.danqzq.games/entry/delete" \
      -H "Accept: */*" \
      -H "Accept-Language: nl-NL,nl;q=0.9,en-US;q=0.8,en;q=0.7" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Content-Type: multipart/form-data; boundary=funniboundrygotmealotoftrouble" \
      -H "Origin: https://html-classic.itch.zone" \
      -H "Pragma: no-cache" \
      -H "Referer: https://html-classic.itch.zone/" \
      -H "Sec-Fetch-Dest: empty" \
      -H "Sec-Fetch-Mode: cors" \
      -H "Sec-Fetch-Site: cross-site" \
      -H "Sec-GPC: 1" \
      -H "Sender: LeaderboardCreatorApp" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36" \
      -H 'sec-ch-ua: "Brave";v="125", "Chromium";v="125", "Not.A/Brand";v="24"' \
      -H "sec-ch-ua-mobile: ?0" \
      -H 'sec-ch-ua-platform: "Windows"' \
      --data-raw "--funniboundrygotmealotoftrouble\r\nContent-Disposition: form-data; name=\"username\"\r\nContent-Type: text/plain; encoding=utf-8\r\n\r\n$Name\r\n--funniboundrygotmealotoftrouble\r\nContent-Disposition: form-data; name=\"publicKey\"\r\nContent-Type: text/plain; encoding=utf-8\r\n\r\n$PublicKey\r\n--funniboundrygotmealotoftrouble--"
    if [ $? -ne 0 ]; then
      echo "Servers are not responding; check your internet connection if this reoccurs. Retrying..."
      exec "$SHELL"
    fi

    # Send Packet 3
    curl -s "https://lcv2-server.danqzq.games/get?secretKey=$SecretKey&skip=0&take=10&username=&timePeriod=0" \
      -X "OPTIONS" \
      -H "Accept: */*" \
      -H "Accept-Language: nl-NL,nl;q=0.9,en-US;q=0.8,en;q=0.7" \
      -H "Access-Control-Request-Headers: sender" \
      -H "Access-Control-Request-Method: GET" \
      -H "Cache-Control: no-cache" \
      -H "Connection: keep-alive" \
      -H "Origin: https://html-classic.itch.zone" \
      -H "Pragma: no-cache" \
      -H "Referer: https://html-classic.itch.zone/" \
      -H "Sec-Fetch-Dest: empty" \
      -H "Sec-Fetch-Mode: cors" \
      -H "Sec-Fetch-Site: cross-site" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
    if [ $? -ne 0 ]; then
      echo "Servers are not responding; check your internet connection if this reoccurs. Retrying..."
      exec "$SHELL"
    fi

    echo "All packets sent, Moving on..."
  fi
done

clear-leaderboard

exec "$SHELL"