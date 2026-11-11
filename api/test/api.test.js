const fs = require('fs');
const path = require('path');
const request = require('supertest');
const { app, pool } = require('../server');

const add = async (name, heightCm) =>
    (await request(app).post('/api/plants').send({ name, heightCm })).body;

beforeAll(async () => {
    // Create the table from your real schema
    await pool.query(fs.readFileSync(path.join(__dirname, '../../db/schema.sql'), 'utf8'));
});

beforeEach(async () => {
    await pool.query('TRUNCATE "Plant" RESTART IDENTITY');
});

afterAll(async () => {
    await pool.end();
});

test('GET /health returns 200', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
});

describe('POST /api/plants', () => {
    test('creates a plant', async () => {
        const res = await request(app).post('/api/plants').send({ name: 'Fern', heightCm: 30 });
        expect(res.status).toBe(201);
        expect(res.body).toEqual({ id: 1, name: 'Fern', heightCm: 30 });
    });

    test('rejects an invalid name', async () => {
        const res = await request(app).post('/api/plants').send({ name: '', heightCm: 30 });
        expect(res.status).toBe(400);
    });

    test('rejects an invalid heightCm', async () => {
        const res = await request(app).post('/api/plants').send({ name: 'Fern', heightCm: -5 });
        expect(res.status).toBe(400);
    });

    test('rejects a missing body', async () => {
        const res = await request(app).post('/api/plants');
        expect(res.status).toBe(400);
    });
});

describe('GET /api/plants', () => {
    test('lists plants', async () => {
        await add('Fern', 30);
        await add('Cactus', 120);

        const res = await request(app).get('/api/plants');
        expect(res.status).toBe(200);
        expect(res.body.map((p) => p.name)).toEqual(['Fern', 'Cactus']);
    });

    test('filters by name (case-insensitive)', async () => {
        await add('Fern', 30);
        await add('Cactus', 120);

        const res = await request(app).get('/api/plants?name=FERN');
        expect(res.body.map((p) => p.name)).toEqual(['Fern']);
    });
});

describe('GET /api/plants/:id', () => {
    test('returns a plant', async () => {
        const { id } = await add('Fern', 30);

        const res = await request(app).get(`/api/plants/${id}`);
        expect(res.status).toBe(200);
        expect(res.body).toEqual({ id, name: 'Fern', heightCm: 30 });
    });

    test('404 when not found', async () => {
        const res = await request(app).get('/api/plants/999');
        expect(res.status).toBe(404);
    });

    test('404 for an invalid id', async () => {
        const res = await request(app).get('/api/plants/abc');
        expect(res.status).toBe(404);
    });
});

describe('DELETE /api/plants/:id', () => {
    test('deletes a plant', async () => {
        const { id } = await add('Fern', 30);

        const res = await request(app).delete(`/api/plants/${id}`);
        expect(res.status).toBe(204);
        expect((await request(app).get(`/api/plants/${id}`)).status).toBe(404);
    });

    test('404 when not found', async () => {
        const res = await request(app).delete('/api/plants/999');
        expect(res.status).toBe(404);
    });
});