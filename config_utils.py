"""Configuration utilities and validation"""

from config import settings
from typing import Set
from logger import app_logger


def validate_configuration() -> bool:
    """Validate that all required configurations are set"""
    
    errors = []
    
    # Check Gemini API Key
    if not settings.gemini_api_key:
        errors.append("GEMINI_API_KEY is not set in environment variables")
    
    # Check file size
    if settings.max_file_size <= 0:
        errors.append("MAX_FILE_SIZE must be greater than 0")
    
    # Check port
    if not (1 <= settings.port <= 65535):
        errors.append("PORT must be between 1 and 65535")
    
    # Check rate limit
    if settings.rate_limit_enabled:
        if settings.rate_limit_requests <= 0:
            errors.append("RATE_LIMIT_REQUESTS must be greater than 0")
        if settings.rate_limit_period <= 0:
            errors.append("RATE_LIMIT_PERIOD must be greater than 0")
    
    # Check cache
    if settings.cache_enabled and not settings.redis_url:
        errors.append("REDIS_URL must be set when CACHE_ENABLED is true")
    
    # Check database
    if settings.database_enabled and not settings.database_url:
        errors.append("DATABASE_URL must be set when DATABASE_ENABLED is true")
    
    if errors:
        for error in errors:
            app_logger.error(f"Configuration Error: {error}")
        return False
    
    return True


def get_allowed_file_types() -> Set[str]:
    """Get set of allowed file types"""
    return set(settings.allowed_file_types)


def is_file_type_allowed(content_type: str) -> bool:
    """Check if file type is allowed"""
    return content_type in get_allowed_file_types()


def get_file_size_limit() -> int:
    """Get file size limit in bytes"""
    return settings.max_file_size


def get_file_size_limit_mb() -> float:
    """Get file size limit in MB"""
    return settings.max_file_size / (1024 * 1024)


def is_cors_enabled() -> bool:
    """Check if CORS is enabled"""
    return settings.cors_enabled


def is_cache_enabled() -> bool:
    """Check if caching is enabled"""
    return settings.cache_enabled


def is_database_enabled() -> bool:
    """Check if database is enabled"""
    return settings.database_enabled


def is_rate_limiting_enabled() -> bool:
    """Check if rate limiting is enabled"""
    return settings.rate_limit_enabled


def print_configuration_summary() -> None:
    """Print configuration summary to logs"""
    
    app_logger.info("=" * 60)
    app_logger.info("OCR API Configuration Summary")
    app_logger.info("=" * 60)
    
    app_logger.info(f"App Name: {settings.app_name}")
    app_logger.info(f"App Version: {settings.app_version}")
    app_logger.info(f"Debug Mode: {settings.debug}")
    
    app_logger.info(f"Server: {settings.host}:{settings.port}")
    app_logger.info(f"Workers: {settings.workers}")
    
    app_logger.info(f"Gemini Model: {settings.gemini_model}")
    app_logger.info(f"Gemini Timeout: {settings.gemini_timeout}s")
    
    app_logger.info(f"Max File Size: {get_file_size_limit_mb():.2f}MB")
    app_logger.info(f"Allowed File Types: {', '.join(settings.allowed_file_types)}")
    
    app_logger.info(f"CORS Enabled: {settings.cors_enabled}")
    app_logger.info(f"Rate Limiting: {settings.rate_limit_enabled}")
    app_logger.info(f"Caching: {settings.cache_enabled}")
    app_logger.info(f"Database: {settings.database_enabled}")
    app_logger.info(f"Health Check: {settings.health_check_enabled}")
    app_logger.info(f"Metrics: {settings.metrics_enabled}")
    
    app_logger.info("=" * 60)
