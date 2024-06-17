@echo off

title Learderboard Wiper - Working...

if not exist Config.ini echo PublicKey="" > Config.ini && echo SecretKey="" >> Config.ini && echo Created Config.ini, Please insert your keys in there! && cmd /k

for /f "tokens=1,2 delims==" %%a in (Config.ini) do (
    if %%a==PublicKey set %%a=%%b
    if %%a==SecretKey set %%a=%%b
)

set PublicKey=%PublicKey:"=%
set SecretKey=%SecretKey:"=%
set PublicKey=%PublicKey: =%
set SecretKey=%SecretKey: =%
if "%PublicKey%"=="" echo Invalid PublicKey! && color 07 && title cmd.exe && cmd /k
if "%SecretKey%"=="" echo Invalid SecretKey! && color 07 && title cmd.exe && cmd /k

@REM Get leaderboard data

for /F "tokens=* USEBACKQ" %%F IN (`curl "https://lcv2-server.danqzq.games/get?publicKey=%PublicKey%"   -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"   -H "Accept-Language: nl-NL,nl;q=0.8"   -H "Cache-Control: no-cache"   -H "Connection: keep-alive"   -H "Pragma: no-cache"   -H "Sec-Fetch-Dest: document"   -H "Sec-Fetch-Mode: navigate"   -H "Sec-Fetch-Site: cross-site"   -H "Sec-Fetch-User: ?1"   -H "Sec-GPC: 1"   -H "Upgrade-Insecure-Requests: 1"   -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"   -H "sec-ch-ua: \"Brave\";v=\"125\", \"Chromium\";v=\"125\", \"Not.A/Brand\";v=\"24\""   -H "sec-ch-ua-mobile: ?0"   -H "sec-ch-ua-platform: \"Windows\""`) DO (
set Users=%%F
)
if %ERRORLEVEL% NEQ 0 echo. && echo Servers are not responding; check your internet connection if this reoccurs. retrying... && echo. && Leaderboard Clear
@REM if "%Username%"==[] echo Done! && color 07 && title cmd.exe && cmd /k
@REM Parse Json

set Users=%Users::==%
set Users=%Users:"=%
if "%Users%"=="[]" echo. && echo Done! && echo. && color 07 && title cmd.exe && cmd /k
set Users=%Users:[=%
set Users=%Users:]=%
set Users=%Users:{=%
set Users=%Users:}=%
set %Users:,=&& set %
set Name=%Username%

echo.
echo Deleting %Name%
echo.

echo Variables Defined! Sending Packet 1...

curl "https://lcv2-server.danqzq.games/entry/delete" ^
  -X "OPTIONS" ^
  -H "Accept: */*" ^
  -H "Accept-Language: nl-NL,nl;q=0.9,en-US;q=0.8,en;q=0.7" ^
  -H "Access-Control-Request-Headers: sender" ^
  -H "Access-Control-Request-Method: POST" ^
  -H "Cache-Control: no-cache" ^
  -H "Connection: keep-alive" ^
  -H "Origin: https://html-classic.itch.zone" ^
  -H "Pragma: no-cache" ^
  -H "Referer: https://html-classic.itch.zone/" ^
  -H "Sec-Fetch-Dest: empty" ^
  -H "Sec-Fetch-Mode: cors" ^
  -H "Sec-Fetch-Site: cross-site" ^
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
IF %ERRORLEVEL% NEQ 0 echo. && echo Servers are not responding; check your internet connection if this reoccurs. retrying... && echo. 

echo Packet 1 sent! Sending Packet 2...

curl "https://lcv2-server.danqzq.games/entry/delete" ^
  -H "Accept: */*" ^
  -H "Accept-Language: nl-NL,nl;q=0.9,en-US;q=0.8,en;q=0.7" ^
  -H "Cache-Control: no-cache" ^
  -H "Connection: keep-alive" ^
  -H "Content-Type: multipart/form-data; boundary=funniboundrygotmealotoftrouble" ^
  -H "Origin: https://html-classic.itch.zone" ^
  -H "Pragma: no-cache" ^
  -H "Referer: https://html-classic.itch.zone/" ^
  -H "Sec-Fetch-Dest: empty" ^
  -H "Sec-Fetch-Mode: cors" ^
  -H "Sec-Fetch-Site: cross-site" ^
  -H "Sec-GPC: 1" ^
  -H "Sender: LeaderboardCreatorApp" ^
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36" ^
  -H ^"sec-ch-ua: ^\^"Brave^\^";v=^\^"125^\^", ^\^"Chromium^\^";v=^\^"125^\^", ^\^"Not.A/Brand^\^";v=^\^"24^\^"^" ^
  -H "sec-ch-ua-mobile: ?0" ^
  -H ^"sec-ch-ua-platform: ^\^"Windows^\^"^" ^
  --data-raw ^"^

--funniboundrygotmealotoftrouble^

Content-Disposition: form-data; name=^\^"username^\^"^

Content-Type: text/plain; encoding=utf-8^

^

%Name%^

--funniboundrygotmealotoftrouble^

Content-Disposition: form-data; name=^\^"publicKey^\^"^

Content-Type: text/plain; encoding=utf-8^

^

%PublicKey%^

--funniboundrygotmealotoftrouble--^

^"
IF %ERRORLEVEL% NEQ 0 echo. && echo Servers are not responding; check your internet connection if this reoccurs. retrying... && echo.

echo Packet 2 sent! Sending Packet 3...

curl "https://lcv2-server.danqzq.games/get?secretKey=%SecretKey%&skip=0&take=10&username=&timePeriod=0" ^
  -X "OPTIONS" ^
  -H "Accept: */*" ^
  -H "Accept-Language: nl-NL,nl;q=0.9,en-US;q=0.8,en;q=0.7" ^
  -H "Access-Control-Request-Headers: sender" ^
  -H "Access-Control-Request-Method: GET" ^
  -H "Cache-Control: no-cache" ^
  -H "Connection: keep-alive" ^
  -H "Origin: https://html-classic.itch.zone" ^
  -H "Pragma: no-cache" ^
  -H "Referer: https://html-classic.itch.zone/" ^
  -H "Sec-Fetch-Dest: empty" ^
  -H "Sec-Fetch-Mode: cors" ^
  -H "Sec-Fetch-Site: cross-site" ^
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
IF %ERRORLEVEL% NEQ 0 echo. && echo Servers are not responding; check your internet connection if this reoccurs. retrying... && echo.

echo All packets sent, Moving on...
echo.

clear-leaderboard