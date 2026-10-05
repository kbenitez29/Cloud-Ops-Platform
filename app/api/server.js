// API server — health check plus first real AWS SDK integration (ECS status)
const http = require('http')
const { ECSClient, DescribeServicesCommand } = require('@aws-sdk/client-ecs')

const PORT = process.env.PORT || 3000
const ENVIRONMENT = process.env.ENVIRONMENT || 'unknown'
const REGION = process.env.AWS_REGION || 'eu-west-1'

// Credentials come from the ECS task role automatically — no keys in code
const ecsClient = new ECSClient({ region: REGION })

const server = http.createServer(async (req, res) => {

  // ALB health check — stays fast, no AWS calls
  if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ status: 'healthy', environment: ENVIRONMENT }))
    return
  }

  // Real platform endpoint — queries live ECS service state
  if (req.url === '/api/ecs/status' && req.method === 'GET') {
    try {
      const command = new DescribeServicesCommand({
        cluster: process.env.ECS_CLUSTER,
        services: [process.env.ECS_API_SERVICE, process.env.ECS_FRONTEND_SERVICE]
      })
      const response = await ecsClient.send(command)

      const services = response.services.map(s => ({
        name: s.serviceName,
        status: s.status,
        runningCount: s.runningCount,
        desiredCount: s.desiredCount,
        healthy: s.runningCount === s.desiredCount
      }))

      res.writeHead(200, { 'Content-Type': 'application/json' })
      res.end(JSON.stringify({ services }))
    } catch (err) {
      res.writeHead(500, { 'Content-Type': 'application/json' })
      res.end(JSON.stringify({ error: err.message }))
    }
    return
  }

  if (req.url === '/' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ name: 'Cloud Ops Platform API', version: '0.2.0' }))
    return
  }

  res.writeHead(404)
  res.end(JSON.stringify({ error: 'Not found' }))
})

server.listen(PORT, () => console.log(`API running on port ${PORT}`))