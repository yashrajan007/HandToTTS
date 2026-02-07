# OCR API using FastAPI and Google Gemini

A high-performance Optical Character Recognition (OCR) API built with FastAPI and powered by Google's Gemini Vision API.

## Features

- **Fast & Efficient**: Built on FastAPI for high performance
- **Google Gemini Vision**: Uses state-of-the-art AI for accurate text extraction
- **Multiple Endpoints**: Standard OCR and custom prompt-based extraction
- **CORS Enabled**: Ready for cross-origin requests
- **File Validation**: Supports JPEG, PNG, GIF, and WebP formats
- **Error Handling**: Comprehensive error messages and validation

## Prerequisites

- Python 3.9 or higher
- Google Gemini API key (get one at https://ai.google.dev/)

## Installation

1. **Clone/Download the project**
   ```bash
   cd "C:\Users\BIT\OneDrive\Desktop\OCR"
   ```

2. **Create a virtual environment** (recommended)
   ```bash
   python -m venv venv
   venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   - Copy `.env.example` to `.env`
   - Add your Gemini API key:
     ```bash
     copy .env.example .env
     ```
   - Edit `.env` and replace `your_api_key_here` with your actual API key

## Getting a Gemini API Key

1. Visit https://ai.google.dev/
2. Click "Get API Key"
3. Create a new API key for your project
4. Copy the key and paste it in your `.env` file

## Running the Server

```bash
python main.py
```

The API will be available at `http://localhost:8000`

### Optional: Run with Uvicorn directly
```bash
uvicorn main:app --reload
```

## API Endpoints

### 1. Health Check
**GET** `/`
```bash
curl http://localhost:8000/
```

**Response:**
```json
{
    "message": "OCR API is running",
    "name": "OCR API",
    "version": "1.0.0"
}
```

### 2. Extract Text from Image
**POST** `/ocr`

Upload an image file to extract text using the default prompt.

```bash
curl -X POST "http://localhost:8000/ocr" \
  -H "accept: application/json" \
  -F "file=@path/to/image.jpg"
```

**Response:**
```json
{
    "success": true,
    "filename": "image.jpg",
    "content_type": "image/jpeg",
    "extracted_text": "The extracted text from the image..."
}
```

### 3. Extract Text with Custom Prompt
**POST** `/ocr-with-prompt`

Extract text with a custom prompt for more specific instructions.

```bash
curl -X POST "http://localhost:8000/ocr-with-prompt" \
  -H "accept: application/json" \
  -F "file=@path/to/image.jpg" \
  -F "prompt=Extract only the prices from this receipt"
```

**Response:**
```json
{
    "success": true,
    "filename": "image.jpg",
    "content_type": "image/jpeg",
    "prompt": "Extract only the prices from this receipt",
    "extracted_text": "The extracted text based on your prompt..."
}
```

## Supported Image Formats

- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)
- WebP (.webp)

**Maximum file size**: 20MB

## Interactive API Documentation

Once the server is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

You can test all endpoints directly from these interfaces!

## Example Usage with Python

```python
import requests

# Upload and extract text
with open("image.jpg", "rb") as f:
    files = {"file": f}
    response = requests.post("http://localhost:8000/ocr", files=files)
    result = response.json()
    print(result["extracted_text"])

# Use custom prompt
with open("receipt.jpg", "rb") as f:
    files = {"file": f}
    data = {"prompt": "Extract all products and prices from this receipt"}
    response = requests.post("http://localhost:8000/ocr-with-prompt", files=files, data=data)
    result = response.json()
    print(result["extracted_text"])
```

## Example Usage with JavaScript/Fetch

```javascript
// Extract text from image
const formData = new FormData();
formData.append('file', fileInput.files[0]);

const response = await fetch('http://localhost:8000/ocr', {
    method: 'POST',
    body: formData
});

const result = await response.json();
console.log(result.extracted_text);
```

## Project Structure

```
OCR/
├── main.py              # FastAPI application
├── config.py            # Configuration settings
├── requirements.txt     # Python dependencies
├── .env.example         # Example environment variables
├── .env                 # Environment variables (create from .env.example)
└── README.md           # This file
```

## Configuration

Edit `config.py` to customize:
- API key (from environment)
- App name and version
- Debug mode

## Error Handling

The API returns appropriate HTTP status codes:

- **200**: Success
- **400**: Invalid file type or request
- **413**: File too large
- **500**: Server error

## Deployment

### Using Gunicorn (Production)

```bash
pip install gunicorn
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:8000
```

### Using Docker

Create a `Dockerfile`:
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t ocr-api .
docker run -p 8000:8000 -e GEMINI_API_KEY=your_key_here ocr-api
```

## Troubleshooting

### "GEMINI_API_KEY not found"
- Make sure you've created a `.env` file with your API key
- Check that the API key is valid at https://ai.google.dev/

### "Invalid file type"
- Ensure your image is one of the supported formats (JPEG, PNG, GIF, WebP)

### "File too large"
- Maximum file size is 20MB. Compress your image or use a smaller file

## License

MIT License

## Support

For issues or questions, check the API documentation at `http://localhost:8000/docs`
