// Unit tests using Node's built-in test runner (no extra libraries needed)
const test = require('node:test');
const assert = require('node:assert');
const app = require('./server');

let server;
let baseUrl;

test.before(() => new Promise((resolve) => {
  server = app.listen(0, () => {
    baseUrl = `http://127.0.0.1:${server.address().port}`;
    resolve();
  });
}));

test.after(() => server.close());

test('GET / returns a welcome message', async () => {
  const res = await fetch(`${baseUrl}/`);
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.match(body.message, /Hello/);
});

test('GET /health returns healthy', async () => {
  const res = await fetch(`${baseUrl}/health`);
  assert.strictEqual(res.status, 200);
  assert.deepStrictEqual(await res.json(), { status: 'healthy' });
});
