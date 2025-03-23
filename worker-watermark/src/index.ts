import { Hono } from 'hono'
import { serveStatic } from 'hono/cloudflare-workers'

interface Env {
  GOOGLE_API_KEY: string;
}

interface ImageData {
  data: string;
  mime_type: string;
}

interface RequestBody {
  image: ImageData;
}

interface GeminiResponse {
  candidates?: Array<{
    content?: {
      parts?: Array<{
        inlineData?: {
          data: string;
        };
      }>;
    };
  }>;
  promptFeedback?: any;
}

const app = new Hono<{ Bindings: Env }>()

app.use('/static/*', serveStatic({ root: './', manifest: {} }))

// API endpoint for watermark removal
app.post('/api/remove-watermark', async (c) => {
  try {
    const body = await c.req.json<RequestBody>()
    const { image } = body

    if (!image?.data) {
      console.error('Missing required image:', {
        hasImage: !!image?.data
      })
      throw new Error('Image is required')
    }

    console.log('Processing image:', {
      imageType: image.mime_type,
      imageDataLength: image.data.length
    })

    const apiKey = c.env?.GOOGLE_API_KEY
    if (!apiKey) {
      throw new Error('API key not configured')
    }

    // Make the API request to Gemini
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
            text: "Remove any watermarks from this image while preserving the original image quality and content. Keep the image exactly the same except for removing the watermark."
          }
        ]
      }],
      generationConfig: {
        temperature: 0.4, // Lower temperature for more consistent results
        topP: 0.8,
        topK: 32,
        maxOutputTokens: 8192,
        responseModalities: ["Text", "Image"]
      }
    }

    const apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp-image-generation:generateContent?key=' + apiKey

    const response = await fetch(
      apiUrl,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody)
      }
    )

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Gemini API error:', {
        status: response.status,
        statusText: response.statusText,
        error: errorText
      })
      throw new Error(`Failed to process image: ${response.status} ${response.statusText}`)
    }

    const data = await response.json()
    const responseData = data as GeminiResponse

    // Extract the image data
    const base64Image = responseData.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data
    if (!base64Image) {
      throw new Error('No image data in response')
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

export default app
