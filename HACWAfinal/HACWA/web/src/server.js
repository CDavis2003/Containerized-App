const express = require('express');
const mustacheExpress = require('mustache-express');
const os = require('os');
const { Pool } = require('pg');
 
const app = express();
app.use(express.static('public'))
app.set('view engine', 'html');
app.engine('html', mustacheExpress());          // register file extension
app.set('views', __dirname);

const port = 3000;
const dbhost = 'webstack_db';
console.log(`DB_HOST test: ${dbhost}`);
const pool = new Pool({
    host: dbhost,
    user: 'dockeruser',
    password: 'dockerpass',
    database: 'medieval_images',
    port: 5432,
})

app.get('/', (req,res) => {
    res.status(200).send('Images from the Medieval World');
});

app.get('/images', async (req, res) => {
    const result = await pool.query('SELECT * FROM castles');
    res.status(200).json({ info: result.rows });
  })
  
app.get('/view', async (req,res) => {
    const imageId = getRandomInt(5) + 1;
    const result = await pool.query('SELECT * FROM castles WHERE imageid=$1', [imageId]);
    const url = result.rows[0].url;
    res.render('index', {
            url: url,
            hostname: os.hostname()
        });
});

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

app.listen(port, '0.0.0.0', () => {
    console.log(`Application listening on port ${port}`)
})
