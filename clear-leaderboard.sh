#!/bin/bash
# Ba_l1k
echo "Leaderboard Wiper - Working..."
# Config.ini dosyas1 yoksa olu_tur
if [ ! -f Config.ini ]; then
  echo "PublicKey=\"\"" > Config.ini
  echo "SecretKey=\"\"" >> Config.ini
  echo "Created Config.ini, Please insert your keys in there!"
  exit
fi
# Config.ini dosyas1n1 oku
while IFS='=' read -r key value; do
  case "$key" in
    "PublicKey") PublicKey="$value" ;;
    "SecretKey") SecretKey="$value" ;;
  esac
done < Config.ini
# Anahtarlar1 temizle
PublicKey=$(echo "$PublicKey" | tr -d '"')
SecretKey=$(echo "$SecretKey" | tr -d '"')
PublicKey=$(echo "$PublicKey" | tr -d ' ')
SecretKey=$(echo "$SecretKey" | tr -d ' ')
# Anahtarlar1n geçerli olup olmad11n1 kontrol et
if [ -z "$PublicKey" ]; then
  echo "Invalid PublicKey!"
  exit
fi
if [ -z "$SecretKey" ]; then
  echo "Invalid SecretKey!"
  exit
fi
# Leaderboard verilerini al
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
  exit
fi
# JSON'u ayr1_t1r
Users=$(echo "$Users" | tr -d '[]{}:"' | tr ',' '\n')
if [ -z "$Users" ]; then
  echo "Done!"
  exit
fi
for Name in $Users; do
  echo "Deleting $Name"
  echo "Variables Defined! Sending Packet 1..."
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
    exit
  fi
  echo "Packet 1 sent! Sending Packet 2..."
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
    -H "sec-ch-ua: \"Brave\";v=\"125\", \"Chromium\";v=\"125\", \"Not.A/Brand\";v=\"24\"" \
    -H "sec-ch-ua-mobile: ?0" \
    -H "sec-ch-ua-platform: \"Windows\"" \
    --data-raw "
--funniboundrygotmealotoftrouble
Content-Disposition: form-data; name=\"username\"
Content-Type: text/plain; encoding=utf-8
$Name
--funniboundrygotmealotoftrouble
Content-Disposition: form-data; name=\"publicKey\"
Content-Type: text/plain; encoding=utf-8
$PublicKey
--funniboundrygotmealotoftrouble--"
  if [ $? -ne 0 ]; then
    echo "Servers are not responding; check your internet connection if this reoccurs. Retrying..."
    exit
  fi
  echo "Packet 2 sent! Sending Packet 3..."
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
    exit
  fi
  echo "All packets sent, Moving on..."
  echo
done
echo "clear-leaderboard"
