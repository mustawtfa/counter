const express = require('express');
const app = express();
const fs = require('fs');
const port = process.env.PORT || 3000;
const keep_alive = require('./keep_alive.js');

const targetTime = new Date('2024-06-14T00:00:00+03:00');
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

  if (totalSeconds < 27500 && !leaderboardFetched) {
    fetch('/wlydan/getLeaderboardFormatted')
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        const filename = `/sezon${resetCount - 1}.txt`;
        fs.writeFile(__dirname + filename, data, (err) => {
          if (err) {
            console.error('Dosya yazma hatası:', err);
          } else {
            console.log(`Leaderboard verileri güncellendi (sezon ${resetCount + 1})`);
            leaderboardFetched = true;
          }
        });
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