const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.send('Hello from the uptime API');
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/check', async (req, res) => {
  const target = req.query.url;

  if (!target) {
    return res.status(400).json({ error: 'Add a url, for example /check?url=https://example.com' });
  }

  let parsed;
  try {
    parsed = new URL(target);
  } catch {
    return res.status(400).json({ error: 'That is not a valid URL' });
  }

  if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') {
    return res.status(400).json({ error: 'Only http and https addresses are allowed' });
  }

  const started = Date.now();
  try {
    const response = await fetch(parsed.href, { signal: AbortSignal.timeout(5000) });
    res.json({
      url: parsed.href,
      up: response.ok,
      statusCode: response.status,
      responseTimeMs: Date.now() - started
    });
  } catch (err) {
    res.json({
      url: parsed.href,
      up: false,
      statusCode: null,
      responseTimeMs: Date.now() - started,
      error: err.message
    });
  }
});

app.listen(PORT, () => {
  console.log('API running on port ' + PORT);
});