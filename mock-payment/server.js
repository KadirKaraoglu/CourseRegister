const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const port = process.env.PORT || 4001

app.use(bodyParser.json())

// Simulate payment processing
// POST /pay { scenario: 'success'|'fail'|'timeout', registration_id }
app.post('/pay', (req, res) => {
  const { scenario, registration_id } = req.body
  if (!scenario) return res.status(400).json({ error: 'scenario required' })

  if (scenario === 'success') {
    // respond quickly with success
    return res.json({ status: 'success', registration_id })
  }

  if (scenario === 'fail') {
    return res.status(402).json({ status: 'failed', registration_id })
  }

  if (scenario === 'timeout') {
    // Simulate long processing time and then drop connection (don't send)
    setTimeout(() => {
      // no response
    }, 120000)
    // send 202 accepted immediately to simulate async; client can still timeout
    return res.status(202).json({ status: 'processing', registration_id })
  }

  return res.status(400).json({ error: 'unknown scenario' })
})

app.listen(port, () => console.log(`Mock payment listening on ${port}`))
