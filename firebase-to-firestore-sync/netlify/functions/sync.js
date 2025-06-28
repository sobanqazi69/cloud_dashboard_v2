// Netlify Function for Firebase to Firestore sync
// This will be publicly accessible without authentication

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

exports.handler = async (event, context) => {
  // Set CORS headers
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-cache'
  };

  // Handle preflight
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    console.log(`[${new Date().toISOString()}] Sync started`);
    
    // Fetch from Realtime Database
    const rtdbResponse = await fetch(`${firebaseConfig.databaseURL}/.json`);
    if (!rtdbResponse.ok) {
      throw new Error(`RTDB Error: ${rtdbResponse.status}`);
    }
    const data = await rtdbResponse.json();

    if (!data) {
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          success: false,
          message: 'No data in Realtime Database',
          timestamp: new Date().toISOString()
        })
      };
    }

    const results = [];
    
    // Process each variable
    for (const variable of VARIABLES) {
      try {
        const value = data[variable];
        
        if (value !== undefined && value !== null) {
          // Save to Firestore
          const timestamp = new Date().toISOString();
          const doc = {
            fields: {
              value: { doubleValue: Number(value) },
              timestamp: { timestampValue: timestamp },
              created_at: { stringValue: timestamp }
            }
          };

          const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${firebaseConfig.projectId}/databases/(default)/documents/${variable}?key=${firebaseConfig.apiKey}`;
          
          const firestoreResponse = await fetch(firestoreUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(doc)
          });

          if (firestoreResponse.ok) {
            results.push({ variable, value: Number(value), success: true });
            console.log(`✅ Saved ${variable}: ${value}`);
          } else {
            const error = await firestoreResponse.text();
            results.push({ variable, success: false, error: `Firestore error: ${error}` });
            console.log(`❌ Failed ${variable}: ${error}`);
          }
        } else {
          results.push({ variable, value: null, success: false, reason: 'null or undefined' });
        }
      } catch (error) {
        results.push({ variable, success: false, error: error.message });
        console.log(`❌ Error processing ${variable}: ${error.message}`);
      }
    }

    const successCount = results.filter(r => r.success).length;
    console.log(`[${new Date().toISOString()}] Sync completed: ${successCount}/${VARIABLES.length}`);

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        message: `Synced ${successCount}/${VARIABLES.length} variables`,
        timestamp: new Date().toISOString(),
        results: results,
        sourceData: data,
        platform: 'netlify'
      })
    };

  } catch (error) {
    console.error(`[${new Date().toISOString()}] Sync failed:`, error);
    
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        success: false,
        message: 'Sync failed',
        error: error.message,
        timestamp: new Date().toISOString(),
        platform: 'netlify'
      })
    };
  }
}; 