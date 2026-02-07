from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
from PIL import Image
import io
import os
from config import settings
from logger import app_logger
from config_utils import (
    validate_configuration,
    is_file_type_allowed,
    get_file_size_limit,
    get_file_size_limit_mb,
    print_configuration_summary
)

# Validate configuration
if not validate_configuration():
    raise RuntimeError("Configuration validation failed!")

# Configure Gemini API
genai.configure(api_key=settings.gemini_api_key)
app_logger.info(f"Gemini API configured with model: {settings.gemini_model}")

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="OCR API using Google Gemini AI"
)

# Add CORS middleware
if settings.cors_enabled:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=settings.cors_credentials,
        allow_methods=settings.cors_methods,
        allow_headers=settings.cors_headers,
    )
    app_logger.info("CORS middleware enabled")

# Print configuration summary on startup
print_configuration_summary()


@app.get("/")
async def root():
    """Health check endpoint"""
    app_logger.info("Health check request received")
    return {
        "message": "OCR API is running",
        "name": settings.app_name,
        "version": settings.app_version
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    app_logger.debug("Health check endpoint called")
    return {"status": "healthy"}


@app.post("/ocr")
async def extract_text(file: UploadFile = File(...)):
    """
    Extract text from an image using Gemini Vision API
    
    Supported formats: JPEG, PNG, GIF, WebP
    """
    app_logger.info(f"OCR request received for file: {file.filename}")
    
    try:
        # Validate file type
        if not is_file_type_allowed(file.content_type):
            allowed_types = ", ".join(settings.allowed_file_types)
            app_logger.warning(f"Invalid file type: {file.content_type}")
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type. Allowed types: {allowed_types}"
            )
        
        # Read the uploaded file
        contents = await file.read()
        
        # Validate file size
        max_size = get_file_size_limit()
        if len(contents) > max_size:
            app_logger.warning(f"File too large: {len(contents)} bytes (max: {max_size})")
            raise HTTPException(
                status_code=413,
                detail=f"File too large. Maximum size is {get_file_size_limit_mb():.2f}MB"
            )
        
        # Convert to PIL Image to validate
        image = Image.open(io.BytesIO(contents))
        app_logger.debug(f"Image validated: {image.format} {image.size}")
        
        # Prepare the image for Gemini API
        image_data = {
            "mime_type": file.content_type,
            "data": contents
        }
        
        # Call Gemini Vision API
        app_logger.info(f"Calling Gemini API with model: {settings.gemini_model}")
        model = genai.GenerativeModel(settings.gemini_model)
        response = model.generate_content([
            "Extract all text from this image. Preserve the layout and structure as much as possible.",
            image_data
        ])
        
        extracted_text = response.text
        app_logger.info(f"Text extraction successful for {file.filename}")
        
        return JSONResponse(
            status_code=200,
            content={
                "success": True,
                "filename": file.filename,
                "content_type": file.content_type,
                "extracted_text": extracted_text
            }
        )
    
    except HTTPException as he:
        raise he
    except Exception as e:
        app_logger.error(f"Error processing image: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error processing image: {str(e)}"
        )


@app.post("/ocr-with-prompt")
async def extract_text_with_prompt(file: UploadFile = File(...), prompt: str = "Extract all text from this image"):
    """
    Extract text from an image using Gemini Vision API with a custom prompt
    """
    app_logger.info(f"OCR with prompt request received for file: {file.filename}")
    
    try:
        # Validate file type
        if not is_file_type_allowed(file.content_type):
            allowed_types = ", ".join(settings.allowed_file_types)
            app_logger.warning(f"Invalid file type: {file.content_type}")
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type. Allowed types: {allowed_types}"
            )
        
        # Read the uploaded file
        contents = await file.read()
        
        # Validate file size
        max_size = get_file_size_limit()
        if len(contents) > max_size:
            app_logger.warning(f"File too large: {len(contents)} bytes")
            raise HTTPException(
                status_code=413,
                detail=f"File too large. Maximum size is {get_file_size_limit_mb():.2f}MB"
            )
        
        # Convert to PIL Image to validate
        image = Image.open(io.BytesIO(contents))
        app_logger.debug(f"Image validated: {image.format} {image.size}")
        
        # Prepare the image for Gemini API
        image_data = {
            "mime_type": file.content_type,
            "data": contents
        }
        
        # Call Gemini Vision API with custom prompt
        app_logger.info(f"Calling Gemini API with custom prompt - Model: {settings.gemini_model}")
        model = genai.GenerativeModel(settings.gemini_model)
        response = model.generate_content([prompt, image_data])
        
        extracted_text = response.text
        app_logger.info(f"Text extraction successful for {file.filename} with custom prompt")
        
        return JSONResponse(
            status_code=200,
            content={
                "success": True,
                "filename": file.filename,
                "content_type": file.content_type,
                "prompt": prompt,
                "extracted_text": extracted_text
            }
        )
    
    except HTTPException as he:
        raise he
    except Exception as e:
        app_logger.error(f"Error processing image with prompt: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error processing image: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn
    
    app_logger.info(f"Starting {settings.app_name} v{settings.app_version}")
    
    uvicorn.run(
        app,
        host=settings.host,
        port=settings.port,
        reload=settings.reload,
        workers=settings.workers,
        log_level=settings.log_level.lower()
    )
