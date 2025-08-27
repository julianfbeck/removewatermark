import { Hono } from 'hono'
import { serveStatic } from 'hono/cloudflare-workers'
import OpenAI from 'openai'

interface Env {
  OPENAI_API_KEY: string;
  GOOGLE_API_KEY: string;
  KV_STATISTICS: KVNamespace;
}

interface ImageData {
  data: string;
  mime_type: string;
}

interface RequestBody {
  image: ImageData;
  removalText?: string;
}


interface Statistics {
  totalRuns: number;
  successfulRuns: number;
  failedRuns: number;
  lastRunTimestamp: string;
  dailyStats: Record<string, DailyStats>;
}

interface DailyStats {
  total: number;
  successful: number;
  failed: number;
}

const app = new Hono<{ Bindings: Env }>()
app.use('/static/*', serveStatic({ root: './', manifest: {} }))

// Root route - display statistics
app.get('/', async (c) => {
  try {
    const stats = await getStatistics(c.env.KV_STATISTICS);

    // Get today's date in YYYY-MM-DD format
    const today = new Date().toISOString().split('T')[0];
    const todayStats = stats.dailyStats[today] || { total: 0, successful: 0, failed: 0 };

    // Get the last 7 days for display
    const last7Days = getLast7Days();
    const dailyStatsHtml = last7Days.map(date => {
      const dayStat = stats.dailyStats[date] || { total: 0, successful: 0, failed: 0 };
      return `<tr>
        <td>${date}</td>
        <td>${dayStat.total}</td>
        <td>${dayStat.successful}</td>
        <td>${dayStat.failed}</td>
        <td>${dayStat.total > 0 ? ((dayStat.successful / dayStat.total) * 100).toFixed(2) + '%' : 'N/A'}</td>
      </tr>`;
    }).join('');

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Untag - Remove Unwanted Elements</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            line-height: 1.6;
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
          }
          .form-group {
            margin-bottom: 15px;
          }
          label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
          }
          input, button {
            padding: 8px;
            border-radius: 4px;
          }
          button {
            background-color: #0066cc;
            color: white;
            border: none;
            padding: 10px 15px;
            cursor: pointer;
          }
          button:hover {
            background-color: #0055aa;
          }
        </style>
      </head>
      <body>
        <h1>Untag - Remove Unwanted Elements</h1>
        
        <h2>Overall Statistics</h2>
        <ul>
          <li>Total Runs: ${stats.totalRuns}</li>
          <li>Successful Runs: ${stats.successfulRuns}</li>
          <li>Failed Runs: ${stats.failedRuns}</li>
          <li>Last Run: ${stats.lastRunTimestamp}</li>
          <li>Success Rate: ${stats.totalRuns > 0 ? ((stats.successfulRuns / stats.totalRuns) * 100).toFixed(2) + '%' : 'N/A'}</li>
        </ul>
        
        <h2>Today's Statistics (${today})</h2>
        <ul>
          <li>Total Runs Today: ${todayStats.total}</li>
          <li>Successful Runs Today: ${todayStats.successful}</li>
          <li>Failed Runs Today: ${todayStats.failed}</li>
          <li>Today's Success Rate: ${todayStats.total > 0 ? ((todayStats.successful / todayStats.total) * 100).toFixed(2) + '%' : 'N/A'}</li>
        </ul>
        
        <h2>Daily Statistics (Last 7 Days)</h2>
        <table border="1">
          <thead>
            <tr>
              <th>Date</th>
              <th>Total</th>
              <th>Successful</th>
              <th>Failed</th>
              <th>Success Rate</th>
            </tr>
          </thead>
          <tbody>
            ${dailyStatsHtml}
          </tbody>
        </table>
        
        <h2>Upload an Image</h2>
        <form id="uploadForm">
          <div class="form-group">
            <label for="imageInput">Select an image:</label>
            <input type="file" id="imageInput" accept="image/*">
          </div>
          <div class="form-group">
            <label for="removalTextInput">What to remove:</label>
            <input type="text" id="removalTextInput" value="watermarks" placeholder="e.g., watermarks, logos, text">
          </div>
          <button type="submit">Untag Image</button>
        </form>
        <div id="result"></div>
        
        <script>
          document.getElementById('uploadForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const fileInput = document.getElementById('imageInput');
            const removalTextInput = document.getElementById('removalTextInput');
            const resultDiv = document.getElementById('result');
            
            if (!fileInput.files || fileInput.files.length === 0) {
              resultDiv.innerHTML = '<p>Please select an image</p>';
              return;
            }
            
            const file = fileInput.files[0];
            const removalText = removalTextInput.value.trim() || 'watermarks';
            const reader = new FileReader();
            
            reader.onload = async () => {
              const base64Data = reader.result.toString().split(',')[1];
              
              resultDiv.innerHTML = '<p>Processing...</p>';
              
              try {
                const response = await fetch('/api/remove-watermark', {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json'
                  },
                  body: JSON.stringify({
                    image: {
                      data: base64Data,
                      mime_type: file.type
                    },
                    removalText: removalText
                  })
                });
                
                if (!response.ok) {
                  const error = await response.json();
                  resultDiv.innerHTML = '<p>Error: ' + (error.error || 'Unknown error') + '</p>';
                  return;
                }
                
                const blob = await response.blob();
                const imgUrl = URL.createObjectURL(blob);
                
                resultDiv.innerHTML = '<h3>Result:</h3><img src="' + imgUrl + '" style="max-width: 100%;">';
                
                // Refresh the page after 2 seconds to update statistics
                setTimeout(() => {
                  window.location.reload();
                }, 2000);
              } catch (error) {
                resultDiv.innerHTML = '<p>Error: ' + error.message + '</p>';
              }
            };
            
            reader.readAsDataURL(file);
          });
        </script>
      </body>
      </html>
    `;

    return c.html(html);
  } catch (error: any) {
    return c.text('Error loading statistics: ' + error.message, 500);
  }
});

// API endpoint for statistics
app.get('/api/stats', async (c) => {
  try {
    const stats = await getStatistics(c.env.KV_STATISTICS);
    return c.json(stats);
  } catch (error: any) {
    console.error('Error retrieving statistics:', error);
    return c.json({
      error: 'Failed to retrieve statistics',
      details: error?.message
    }, 500);
  }
})

// API endpoint for watermark removal
app.post('/api/remove-watermark', async (c) => {
  try {
    const body = await c.req.json<RequestBody>()
    const { image, removalText = 'watermarks' } = body

    // Update total runs counter
    await incrementStatCounter(c.env.KV_STATISTICS, 'totalRuns');
    await updateLastRunTimestamp(c.env.KV_STATISTICS);

    // Update daily statistics - total
    await incrementDailyCounter(c.env.KV_STATISTICS, 'total');

    if (!image?.data) {
      console.error('Missing required image:', {
        hasImage: !!image?.data
      })
      // Increment failed runs counter
      await incrementStatCounter(c.env.KV_STATISTICS, 'failedRuns');
      // Update daily statistics - failed
      await incrementDailyCounter(c.env.KV_STATISTICS, 'failed');
      throw new Error('Image is required')
    }

    console.log('Processing image:', {
      imageType: image.mime_type,
      imageDataLength: image.data.length,
      removalTarget: removalText
    })

    // Try Gemini first, then fall back to OpenAI
    let base64Image: string;
    
    try {
      // Try Gemini API first
      const googleApiKey = c.env?.GOOGLE_API_KEY;
      if (googleApiKey) {
        console.log('Trying Gemini API first...');
        base64Image = await tryGeminiAPI(googleApiKey, image, removalText);
      } else {
        throw new Error('No Google API key available, trying OpenAI...');
      }
    } catch (geminiError) {
      console.log('Gemini failed, trying OpenAI:', geminiError);
      
      // Fall back to OpenAI
      const openaiApiKey = c.env?.OPENAI_API_KEY;
      if (!openaiApiKey) {
        // Increment failed runs counter
        await incrementStatCounter(c.env.KV_STATISTICS, 'failedRuns');
        // Update daily statistics - failed
        await incrementDailyCounter(c.env.KV_STATISTICS, 'failed');
        throw new Error('Neither Google nor OpenAI API keys configured');
      }
      
      base64Image = await tryOpenAIAPI(openaiApiKey, image, removalText);
    }

    // Convert base64 to blob
    const binaryData = atob(base64Image)
    const uint8Array = new Uint8Array(binaryData.length)
    for (let i = 0; i < binaryData.length; i++) {
      uint8Array[i] = binaryData.charCodeAt(i)
    }
    const blob = new Blob([uint8Array], { type: 'image/png' })

    console.log('Created processed image blob:', {
      size: blob.size,
      type: blob.type
    })

    // Increment successful runs counter
    await incrementStatCounter(c.env.KV_STATISTICS, 'successfulRuns');
    // Update daily statistics - successful
    await incrementDailyCounter(c.env.KV_STATISTICS, 'successful');

    return new Response(blob, {
      headers: { 'Content-Type': 'image/png' }
    })
  } catch (error: any) {
    console.error('Error in /api/remove-watermark:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause
    })
    return c.json({
      error: error?.message || 'Unknown error',
      details: error?.stack
    }, 500)
  }
})

// API helper functions
async function tryGeminiAPI(apiKey: string, image: ImageData, removalText: string): Promise<string> {
  const requestBody = {
    contents: [{
      role: "user",
      parts: [
        {
          inline_data: {
            mime_type: image.mime_type,
            data: image.data
          }
        },
        {
          text: `Remove ${removalText} from this image while preserving the original image quality and content. Keep the image exactly the same except for removing the ${removalText}.`
        }
      ]
    }],
    generationConfig: {
      temperature: 1,
      topP: 0.95,
      topK: 40,
      maxOutputTokens: 8192,
      responseModalities: ["Text", "Image"]
    }
  };

  const apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp-image-generation:generateContent?key=' + apiKey;
  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(requestBody)
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Gemini API error: ${response.status} ${response.statusText} - ${errorText}`);
  }

  const data = await response.json() as any;
  const base64Image = data.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
  if (!base64Image) {
    throw new Error('No image data in Gemini response');
  }
  
  return base64Image;
}

async function tryOpenAIAPI(apiKey: string, image: ImageData, removalText: string): Promise<string> {
  const client = new OpenAI({ apiKey });

  // Convert base64 image to File for OpenAI
  const imageBytes = Uint8Array.from(atob(image.data), c => c.charCodeAt(0));
  const imageFile = new File([imageBytes], 'image.jpg', { type: image.mime_type });

  const response = await client.images.edit({
    model: "gpt-image-1",
    image: imageFile,
    n: 1,
    quality: "medium",
    prompt: `Remove ${removalText} from this image while preserving the original image quality and content. Keep the image exactly the same except for removing the ${removalText}.`
  });

  const base64Image = response.data?.[0]?.b64_json;
  if (!base64Image) {
    throw new Error('No image data in OpenAI response');
  }
  
  return base64Image;
}

// Helper functions for statistics
async function getStatistics(kv: KVNamespace): Promise<Statistics> {
  // Try to get existing stats
  const statsString = await kv.get('statistics');

  if (statsString) {
    const stats = JSON.parse(statsString);
    // Ensure dailyStats exists
    if (!stats.dailyStats) {
      stats.dailyStats = {};
    }
    return stats;
  }

  // Initialize stats if they don't exist
  const defaultStats: Statistics = {
    totalRuns: 0,
    successfulRuns: 0,
    failedRuns: 0,
    lastRunTimestamp: new Date().toISOString(),
    dailyStats: {}
  };

  await kv.put('statistics', JSON.stringify(defaultStats));
  return defaultStats;
}

async function incrementStatCounter(kv: KVNamespace, counterName: keyof Statistics): Promise<void> {
  const stats = await getStatistics(kv);

  if (typeof stats[counterName] === 'number') {
    (stats[counterName] as unknown) = ((stats[counterName] as number) + 1);
    await kv.put('statistics', JSON.stringify(stats));
  }
}

async function updateLastRunTimestamp(kv: KVNamespace): Promise<void> {
  const stats = await getStatistics(kv);
  stats.lastRunTimestamp = new Date().toISOString();
  await kv.put('statistics', JSON.stringify(stats));
}

// Function to increment daily counters
async function incrementDailyCounter(kv: KVNamespace, counterType: keyof DailyStats): Promise<void> {
  const stats = await getStatistics(kv);
  const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format

  // Initialize today's stats if they don't exist
  if (!stats.dailyStats[today]) {
    stats.dailyStats[today] = {
      total: 0,
      successful: 0,
      failed: 0
    };
  }

  // Increment the specified counter
  stats.dailyStats[today][counterType]++;

  // Save updated stats
  await kv.put('statistics', JSON.stringify(stats));
}

// Helper function to get the last 7 days in YYYY-MM-DD format
function getLast7Days(): string[] {
  const result = [];
  for (let i = 0; i < 7; i++) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    result.push(date.toISOString().split('T')[0]);
  }
  return result;
}

export default app