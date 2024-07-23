const express = require('express');
const app = express();
const fs = require('fs');
const fetch = require('node-fetch');
const path = require('path');
const port = process.env.PORT || 3000;
const { exec } = require('child_process');
// M<3
const targetTime = new Date('2024-08-23T08:42:00+03:00');
const intervalMilliseconds = 14 * 24 * 60 * 60 * 1000; 
const extendedIntervalMilliseconds = 30 * 24 * 60 * 60 * 1000; 

let resetCount = 5;
let leaderboardFetched = false;
let leaderboardResetted = false;

const leaderboardUrl = 'https://lcv2-server.danqzq.games/get?publicKey=5830625ddabd61108a0b079b05ab593914b104bd796a642200be28187e16022e';

app.get('/', (req, res) => {
  res.send('Sayaç uygulamasına hoş geldiniz!');
});

app.get('/counter', (req, res) => {
  const now = new Date();
  let elapsedMilliseconds = targetTime - now;
  let totalSeconds;
  
  if (resetCount === 5) {
    totalSeconds = (elapsedMilliseconds % extendedIntervalMilliseconds) / 1000;
  } else {
    totalSeconds = (elapsedMilliseconds % intervalMilliseconds) / 1000;
  }

  res.json({ seconds: Math.floor(totalSeconds), resets: resetCount });
});

app.set('view engine', 'ejs');
app.use(express.static(__dirname));

app.get('/sezon:numara', (req, res) => {
  const sezonNumarasi = req.params.numara;
  const filename = `/sezon${sezonNumarasi}.txt`;

  if (!leaderboardFetched) {
    res.status(503).send('Leaderboard verileri henüz hazır değil.');
    return;
  }

  fs.readFile(__dirname + filename, 'utf8', (err, data) => {
    if (err) {
      console.error('Dosya okuma hatası:', err);
      res.status(500).send('Leaderboard verileri okunamadı.');
    } else {
      res.render('leaderboard', { sezonNumarasi, leaderboardVerisi: data });
    }
  });
});

function checkAndFetchLeaderboard() {
  const now = new Date();
  let elapsedMilliseconds = targetTime - now;
  let totalSeconds;
  
  if (resetCount === 5) {
    totalSeconds = (elapsedMilliseconds % extendedIntervalMilliseconds) / 1000;
  } else {
    totalSeconds = (elapsedMilliseconds % intervalMilliseconds) / 1000;
  }

  if ((resetCount === 5 && totalSeconds >= (30 * 24 * 60 * 60 - 60)) || 
      (resetCount > 5 && totalSeconds >= (14 * 24 * 60 * 60 - 60)) && 
      !leaderboardFetched) {
    fetchLeaderboard();
  }
}

setInterval(checkAndFetchLeaderboard, 1000); 

app.listen(port, () => {
  console.log(`Sunucu ${port} portunda çalışıyor.`);
});

function fetchLeaderboard() {
  fetch(leaderboardUrl)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP hata! Durum: ${response.status}`);
      }
      return response.text();
    })
    .then(async data => {
      try {
        const leaderboardData = JSON.parse(data);
        const top100 = leaderboardData.slice(0, 100).map(entry => ({
          Username: entry.Username,
          Score: entry.Score,
          Rank: entry.Rank
        }));
        const formattedData = top100.map(entry => `${entry.Username} | ${entry.Score} | ${entry.Rank}.`).join('\n');
        const filename = `/sezon${resetCount}.txt`;
        const filePath = path.join(__dirname, filename);
        await fs.promises.writeFile(filePath, formattedData);
        console.log(`Leaderboard verileri güncellendi ve "${filePath}" dosyasına yazıldı.`);
        leaderboardFetched = true;
      } catch (error) {
        console.error('Leaderboard verileri işlenirken hata oluştu:', error);
      }
    })
    .catch(error => {
      console.error('Leaderboard verileri alınamadı:', error);
    });
}

function resetLeaderboard() {
  const batchFilePath = path.join(__dirname, 'clear-leaderboard.sh');

  exec(batchFilePath, (error, stdout, stderr) => {
    if (error) {
      console.error(`Dosya çalıştırma hatası: ${error}`);
      return;
    }
    console.log(`Dosya çıktısı: ${stdout}`);

    setInterval(checkLeaderboardData, 10000);
  });
}

function checkLeaderboardData() {
  fetch(leaderboardUrl)
    .then(response => response.text())
    .then(data => {
      if (data.trim() === '') {
        leaderboardResetted = true;
        console.log("Veri yok, leaderboardResetted true yapıldı.");
      } else {
        clearInterval(checkLeaderboardData);
        leaderboardResetted = false;
        console.log("Veri bulundu, leaderboardResetted false yapıldı.");
      }
    })
    .catch(error => {
      console.error('Leaderboard verileri kontrol edilirken hata oluştu:', error);
    });
}
