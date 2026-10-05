// Infrastructure health dashboard — fetches live ECS status from the API
import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [services, setServices] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    // Calls the API through the ALB's /api/* path routing
    fetch('/api/ecs/status')
      .then(res => res.json())
      .then(data => {
        setServices(data.services)
        setLoading(false)
      })
      .catch(err => {
        setError(err.message)
        setLoading(false)
      })
  }, [])

  // Overall health: true only if every service is running its desired count
  const allHealthy = services.length > 0 && services.every(s => s.healthy)

  return (
    <div className="dashboard">
      <header>
        <h1>Cloud Ops Platform</h1>
        <p className="subtitle">Infrastructure Health Overview</p>
      </header>

      {loading && <p className="status-text">Loading infrastructure status...</p>}
      {error && <p className="status-text error">Error: {error}</p>}

      {!loading && !error && (
        <>
          <div className={`overall-status ${allHealthy ? 'healthy' : 'degraded'}`}>
            {allHealthy ? '✓ All systems operational' : '⚠ Degraded performance detected'}
          </div>

          <div className="service-grid">
            {services.map(service => (
              <div key={service.name} className={`service-card ${service.healthy ? 'healthy' : 'unhealthy'}`}>
                <div className="service-header">
                  <h3>{service.name}</h3>
                  <span className={`badge ${service.healthy ? 'healthy' : 'unhealthy'}`}>
                    {service.healthy ? 'Healthy' : 'Degraded'}
                  </span>
                </div>
                <div className="service-metrics">
                  <div className="metric">
                    <span className="metric-label">Running</span>
                    <span className="metric-value">{service.runningCount}</span>
                  </div>
                  <div className="metric">
                    <span className="metric-label">Desired</span>
                    <span className="metric-value">{service.desiredCount}</span>
                  </div>
                  <div className="metric">
                    <span className="metric-label">Status</span>
                    <span className="metric-value">{service.status}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  )
}

export default App