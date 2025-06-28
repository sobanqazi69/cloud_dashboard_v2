// Firebase configuration
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

// Variable names for collections
const VARIABLES = [
  'oxygen_flow',
  'oxygen_pressure', 
  'oxygen_purity',
  'running_hours',
  'temp_1'
];

async function getDataFromRealtimeDB() {
  try {
    console.log('Fetching data from Realtime Database...');
    
    const response = await fetch(`${firebaseConfig.databaseURL}/.json`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    console.log('Retrieved data from RTDB:', data);
    
    return data;
  } catch (error) {
    console.error('Error fetching from Realtime Database:', error.message);
    throw error;
  }
}

async function saveToFirestore(variable, value) {
  try {
    const timestamp = new Date().toISOString();
    const document = {
      fields: {
        value: {
          doubleValue: Number(value)
        },
        timestamp: {
          timestampValue: timestamp
        },
        created_at: {
          stringValue: timestamp
        }
      }
    };

    const url = `https://firestore.googleapis.com/v1/projects/${firebaseConfig.projectId}/databases/(default)/documents/${variable}?key=${firebaseConfig.apiKey}`;
    
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(document)
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Firestore API error: ${response.status} - ${errorText}`);
    }

    const result = await response.json();
    console.log(`Saved ${variable}: ${value} to Firestore`);
    return result;
  } catch (error) {
    console.error(`Error saving ${variable} to Firestore:`, error.message);
    throw error;
  }
}

async function syncDataToFirestore() {
  try {
    console.log('Starting data sync process...');
    
    // Get current data from Realtime Database
    const data = await getDataFromRealtimeDB();
    
    if (!data) {
      console.log('No data found in Realtime Database');
      return { success: false, message: 'No data found' };
    }

    const results = [];
    
    // Store each variable in its respective collection
    for (const variable of VARIABLES) {
      try {
        const value = data[variable];
        
        if (value !== undefined && value !== null) {
          const result = await saveToFirestore(variable, value);
          results.push({ variable, value, success: true });
          console.log(`Successfully processed ${variable}: ${value}`);
        } else {
          console.log(`Warning: ${variable} is undefined or null`);
          results.push({ variable, value: null, success: false, reason: 'undefined or null' });
        }
      } catch (error) {
        console.error(`Error processing ${variable}:`, error.message);
        results.push({ variable, success: false, error: error.message });
      }
    }

    console.log('Sync process completed');
    
    return {
      success: true,
      message: 'Data sync completed',
      timestamp: new Date().toISOString(),
      data: data,
      results: results
    };
    
  } catch (error) {
    console.error('Error in syncDataToFirestore:', error.message);
    throw error;
  }
}

// Main handler function for Vercel
export default async function handler(req, res) {
  try {
    console.log('Sync function called at:', new Date().toISOString());
    console.log('Request method:', req.method);
    console.log('Request headers:', JSON.stringify(req.headers, null, 2));
    
    // Set CORS headers for public access
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
    
    // Handle preflight requests
    if (req.method === 'OPTIONS') {
      console.log('Handling OPTIONS request');
      return res.status(200).end();
    }

    // Allow both GET and POST methods
    if (req.method !== 'GET' && req.method !== 'POST') {
      console.log('Method not allowed:', req.method);
      return res.status(405).json({
        success: false,
        message: 'Method not allowed',
        allowedMethods: ['GET', 'POST']
      });
    }

    console.log('Starting sync process...');
    
    // Sync data
    const result = await syncDataToFirestore();
    
    console.log('Sync completed successfully');
    
    return res.status(200).json({
      success: true,
      message: 'Data synced successfully',
      timestamp: new Date().toISOString(),
      result: result,
      source: 'webhook'
    });
    
  } catch (error) {
    console.error('Handler error:', error.message);
    console.error('Stack trace:', error.stack);
    
    return res.status(500).json({
      success: false,
      message: 'Sync failed',
      error: error.message,
      timestamp: new Date().toISOString(),
      source: 'webhook'
    });
  }
} 