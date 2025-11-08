"""
Database session management for Yaman Workshop Management System
"""
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from models import Base

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is not set")

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300,
    pool_size=10,
    max_overflow=20,
    echo=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    """
    Dependency function to get database session
    Usage in FastAPI:
        from database import get_db
        @app.get("/")
        def endpoint(db: Session = Depends(get_db)):
            ...
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """
    Initialize database tables (only for development/testing)
    Production should use proper migration tools
    """
    Base.metadata.create_all(bind=engine)


def get_session() -> Session:
    """
    Get a database session directly (without dependency injection)
    Remember to close the session when done
    """
    return SessionLocal()
