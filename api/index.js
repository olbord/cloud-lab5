const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

app.use(express.json());

app.get('/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.status(200).json({ status: 'ok' });
    } catch (err) {
        res.sendStatus(503);
    }
});

app.get('/api/plants', async (req, res) => {
    const { name } = req.query;

    let sql = 'SELECT id, name, height_cm AS "heightCm" FROM "Plant"';
    const params = [];

    if (typeof name === 'string' && name.trim() !== '') {
        sql += ' WHERE name ILIKE $1';
        params.push(`%${name.trim()}%`);
    }

    sql += ' ORDER BY id';

    const { rows } = await pool.query(sql, params);
    res.status(200).json(rows);
});

app.post('/api/plants', async (req, res) => {
    const body = req.body;

    if (body === null || typeof body !== 'object' || Array.isArray(body)) {
        return res.status(400).json({ error: 'no req body'});
    }

    const { name, heightCm } = body;

    if (typeof name !== 'string' || name.length < 1 || name.length > 100 || name.includes('\u0000')) {
        return res.status(400).json({ error: 'name must be a string of 1-100 characters' });
    }

    if (!Number.isInteger(heightCm) || heightCm < 0 || heightCm > 1000000) {
        return res.status(400).json({ error: 'heightCm must be an integer between 0 and 1000000' });
    }

    try {
        const { rows } = await pool.query(
            'INSERT INTO "Plant" (name, height_cm) VALUES ($1, $2) RETURNING id, name, height_cm AS "heightCm"',
            [name, heightCm]
        );
        res.status(201).json(rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.get('/api/plants/:id', async (req, res) => {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id < 1) {
        return res.status(404).json({ error: 'id not positive integer' });
    }

    const { rows } = await pool.query(
        'SELECT id, name, height_cm AS "heightCm" FROM "Plant" WHERE id = $1',
        [id]
    );
    if (rows.length === 0) {
        return res.status(404).json({ error: 'not found' });
    }
    res.status(200).json(rows[0]);
});

app.delete('/api/plants/:id', async (req, res) => {
    const { rowCount } = await pool.query(
        'DELETE FROM "Plant" WHERE id = $1',
        [req.params.id]
    );
    if (rowCount === 0) {
        return res.status(404).json({ error: 'not found' });
    }
    res.status(204).end();
});

// Only listen if this file is run directly (not required by Jest tests)
if (require.main === module) {
    app.listen(PORT, '0.0.0.0', async () => {
        console.log(`API running on port ${PORT}`);

        try {
            const res = await fetch(`http://localhost:${PORT}/health`);
            console.log(`Self-check /health -> ${res.status} ${await res.text()}`);
        } catch (err) {
            console.error('Self-check failed:', err.message);
        }
    });
}

module.exports = { app, pool };
