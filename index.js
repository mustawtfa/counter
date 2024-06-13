const express = require('express');
const app = express();
const fs = require('fs');
const fetch = require('node-fetch');
const path = require('path');
const port = process.env.PORT || 3000;
const keep_alive = require('./keep_alive.js');

const targetTime = new Date('2024-06-17T00:00:00+03:00');
const intervalMilliseconds = 7 * 24 * 60 * 60 * 1000;
let resetCount = 0;
let leaderboardFetched = false;

app.get('/', (req, res) => {
  res.send('Sayaç uygulamasına hoş geldiniz!');
});

app.get('/counter', (req, res) => {
  const now = new Date();
  const elapsedMilliseconds = now - targetTime;
  const totalSeconds = elapsedMilliseconds % intervalMilliseconds / 1000;

  if (totalSeconds < 1 && elapsedMilliseconds >= 1) {
    resetCount++;
    leaderboardFetched = false;
  }

  const leaderboardUrl = 'https://lcv2-server.danqzq.games/get?publicKey=4dda90b6e733cdccd3d1df587094f5a7f2d995c5b2f4163cbac64a07a1e854f9';

  if (totalSeconds < 20000 && !leaderboardFetched) {
    fetch(leaderboardUrl)
      .then(response => response.text())
      .then(async data => {
        // Verileri JSON'a dönüştürme
        const leaderboardData = JSON.parse(data);

        // İlk 100 kişiyi alma ve düzenleme
        const top100 = leaderboardData
          .slice(0, 100)
          .map(entry => ({
            Username: entry.Username,
            Score: entry.Score,
            Rank: entry.Rank
          }));

        // Düzenlenmiş verileri metin olarak formatlama
        const formattedData = top100
          .map(entry => `${entry.Username} | ${entry.Score} | ${entry.Rank}.`)
          .join('\n');

        const filename = `/sezon${resetCount - 1}.txt`;
        const filePath = path.join(__dirname, filename);
        await fs.promises.writeFile(filePath, formattedData);
        console.log(`Leaderboard verileri güncellendi ve "${filePath}" dosyasına yazıldı.`);
        leaderboardFetched = true;
      })
      .catch(error => {
        console.error('Leaderboard verileri alınamadı:', error);
      });
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

app.listen(port, () => {
  console.log(`Sunucu ${port} portunda çalışıyor.`);
});