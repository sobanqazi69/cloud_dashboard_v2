// Public webhook endpoint for Firebase to Firestore sync
// This endpoint is designed to be called by cron services and is publicly accessible

const firebaseConfig = {
  apiKey: "AIzaSyDdIsJl581l1z2D68-Q-at4KLtHgF61gbc",
  authDomain: "node-red-75bfc.firebaseapp.com",
  databaseURL: "https://node-red-75bfc-default-rtdb.firebaseio.com",
  projectId: "node-red-75bfc",
  storageBucket: "node-red-75bfc.firebasestorage.app",
  messagingSenderId: "796326449899",
  appId: "1:796326449899:web:b5bd56d3ed7922251264ae",
  measurementId: "G-X1T1NCRPPD"
};

const VARIABLES = ['oxygen_flow', 'oxygen_pressure', 'oxygen_purity', 'running_hours', 'temp_1'];

async function fetchRealtimeData() {
  try {
    const response = await fetch(`${firebaseConfig.databaseURL}/.json`);
    if (!response.ok) throw new Error(`RTDB Error: ${response.status}`);
    return await response.json();
  } catch (error) {
    throw new Error(`Failed to fetch from Realtime DB: ${error.message}`);
  }
}

async function saveToFirestore(variable, value) {
  try {
    const timestamp = new Date().toISOString();
    const doc = {
      fields: {
        value: { doubleValue: Number(value) },
        timestamp: { timestampValue: timestamp },
        created_at: { stringValue: timestamp }
      }
    };

    const url = `https://firestore.googleapis.com/v1/projects/${firebaseConfig.projectId}/databases/(default)/documents/${variable}?key=${firebaseConfig.apiKey}`;
    
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(doc)
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Firestore Error: ${response.status} - ${error}`);
    }

    return await response.json();
  } catch (error) {
    throw new Error(`Failed to save ${variable}: ${error.message}`);
  }
}

async function syncProcess() {
  const startTime = Date.now();
  const results = [];
  
  try {
    // Fetch current data
    const data = await fetchRealtimeData();
    
    if (!data) {
      return { success: false, message: 'No data in Realtime Database', results: [] };
    }

    // Process each variable
    for (const variable of VARIABLES) {
      try {
        const value = data[variable];
        
        if (value !== undefined && value !== null) {
          await saveToFirestore(variable, value);
          results.push({ 
            variable, 
            value: Number(value), 
            success: true, 
            timestamp: new Date().toISOString() 
          });
        } else {
          results.push({ 
            variable, 
            value: null, 
            success: false, 
            reason: 'Value is null or undefined' 
          });
        }
      } catch (error) {
        results.push({ 
          variable, 
          success: false, 
          error: error.message 
        });
      }
    }

    const duration = Date.now() - startTime;
    const successCount = results.filter(r => r.success).length;
    
    return {
      success: true,
      message: `Synced ${successCount}/${VARIABLES.length} variables`,
      duration: `${duration}ms`,
      timestamp: new Date().toISOString(),
      sourceData: data,
      results: results
    };
    
  } catch (error) {
    return {
      success: false,
      message: 'Sync failed',
      error: error.message,
      duration: `${Date.now() - startTime}ms`,
      timestamp: new Date().toISOString(),
      results: results
    };
  }
}

// Main handler - designed to be publicly accessible
module.exports = async (req, res) => {
  // Set headers for public access
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('X-Robots-Tag', 'noindex');
  
  // Handle preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow GET and POST
  if (!['GET', 'POST'].includes(req.method)) {
    return res.status(405).json({
      success: false,
      message: 'Method not allowed',
      allowedMethods: ['GET', 'POST']
    });
  }

  try {
    console.log(`[${new Date().toISOString()}] Webhook called - Method: ${req.method}`);
    
    const result = await syncProcess();
    
    const statusCode = result.success ? 200 : 500;
    
    console.log(`[${new Date().toISOString()}] Sync completed - Success: ${result.success}`);
    
    return res.status(statusCode).json({
      ...result,
      webhook: true,
      endpoint: '/api/webhook',
      userAgent: req.headers['user-agent'] || 'unknown'
    });
    
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Webhook error:`, error);
    
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
      timestamp: new Date().toISOString(),
      webhook: true,
      endpoint: '/api/webhook'
    });
  }
}; 