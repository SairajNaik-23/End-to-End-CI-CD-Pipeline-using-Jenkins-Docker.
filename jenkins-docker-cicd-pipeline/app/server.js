// Simple Express web app deployed by the Jenkins pipeline.
const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || 'dev';

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from the Jenkins + Docker CI/CD pipeline!',
    version: VERSION,
    host: os.hostname(),
  });
});

// Used by the pipeline smoke test and the Docker HEALTHCHECK
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Start the server only when run directly (not when imported by tests)
if (require.main === module) {
  app.listen(PORT, () => console.log(`App listening on port ${PORT}, version ${VERSION}`));
}

module.exports = app;
