// Minimal HTTP server — placeholder until real platform API is built
const http = require('http')

const PORT = process.env.PORT || 3000
const ENVIRONMENT = process.env.ENVIRONMENT || 'unknown'

const server = http.createServer((req, res) => {

  // ALB hits this every 30s — must return 200 or tasks get marked unhealthy
  if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({
      status: 'healthy',
      environment: ENVIRONMENT,
      timestamp: new Date().toISOString()
    }))
    return
  }

  // Placeholder root — will become the platform API
  if (req.url === '/' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({
      name: 'Cloud Ops Platform API',
      version: '0.1.0',
      environment: ENVIRONMENT
    }))
    return
  }

  res.writeHead(404)
  res.end(JSON.stringify({ error: 'Not found' }))
})

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${ENVIRONMENT}`)
})