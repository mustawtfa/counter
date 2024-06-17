const express = require('express');
const app = express();
const fs = require('fs');
const fetch = require('node-fetch');
const path = require('path');
const port = process.env.PORT || 3000;
const { exec } = require('child_process'); // exec fonksiyonunu burada tanımlayalım

const targetTime = new Date('2024-06-17T00:00:00+03:00');
const intervalMilliseconds = 7 * 24 * 60 * 60 * 1000; // 7 gün
let resetCount = 1;
let leaderboardFetched = false;

const leaderboardUrl = 'https://lcv2-server.danqzq.games/get?publicKey=4dda90b6e733cdccd3d1df587094f5a7f2d995c5b2f4163cbac64a07a1e854f9';

app.get('/', (req, res) => {
  res.send('Sayaç uygulamasına hoş geldiniz!');
});

app.get('/counter', (req, res) => {
  const now = new Date();
  const elapsedMilliseconds = now - targetTime;
  const totalSeconds = elapsedMilliseconds % intervalMilliseconds / 1000;

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
  const elapsedMilliseconds = now - targetTime;
  const totalSeconds = elapsedMilliseconds % intervalMilliseconds / 1000;

  if (totalSeconds < 1 && elapsedMilliseconds >= 1) {
    resetCount++;
    leaderboardFetched = false;
  }

  if (totalSeconds > 604800 && !leaderboardFetched) {
    fetchLeaderboard();
  }

  if (totalSeconds < 604800 && totalSeconds > 0) {
    resetLeaderboard();
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
        const filename = `/sezon${resetCount - 1}.txt`;
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
  const batchFilePath = path.join(__dirname, 'clear-leaderboard.bat');

  exec(batchFilePath, (error, stdout, stderr) => {
    if (error) {
      console.error(`Batch dosyası çalıştırma hatası: ${error}`);
      return;
    }
    console.log(`Batch dosyası çıktısı: ${stdout}`);
  });
}