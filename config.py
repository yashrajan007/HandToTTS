from pydantic_settings import BaseSettings
import os
from typing import List


class Settings(BaseSettings):
    """Application settings and configuration"""
    
    # API Configuration
    app_name: str = "OCR API"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # Server Configuration
    host: str = "0.0.0.0"
    port: int = 8000
    reload: bool = False
    workers: int = 1
    
    # Gemini API Configuration
    gemini_api_key: str = os.getenv("GEMINI_API_KEY", "")
    gemini_model: str = "gemini-2.0-flash"
    gemini_timeout: int = 60  # seconds
    
    # File Upload Configuration
    max_file_size: int = 20 * 1024 * 1024  # 20MB
    allowed_file_types: List[str] = [
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp"
    ]
    
    # API Rate Limiting
    rate_limit_enabled: bool = False
    rate_limit_requests: int = 100
    rate_limit_period: int = 3600  # 1 hour
    
    # CORS Configuration
    cors_enabled: bool = True
    cors_origins: List[str] = ["*"]
    cors_credentials: bool = True
    cors_methods: List[str] = ["*"]
    cors_headers: List[str] = ["*"]
    
    # Logging Configuration
    log_level: str = "INFO"
    log_format: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    log_file: str = "ocr_api.log"
    enable_file_logging: bool = False
    
    # Request Configuration
    request_timeout: int = 30
    max_retries: int = 3
    
    # Security Configuration
    allowed_hosts: List[str] = ["*"]
    enable_https_redirect: bool = False
    
    # Cache Configuration (Optional)
    cache_enabled: bool = False
    cache_ttl: int = 3600  # 1 hour
    redis_url: str = ""
    
    # Database Configuration (Optional)
    database_enabled: bool = False
    database_url: str = ""
    
    # Monitoring Configuration
    health_check_enabled: bool = True
    metrics_enabled: bool = False
    
    class Config:
        env_file = ".env"
        case_sensitive = False
        extra = "allow"  # Allow extra fields from .env


settings = Settings()
