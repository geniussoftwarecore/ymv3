import os
import uuid
from pathlib import Path
from typing import Optional, List
from fastapi import UploadFile, HTTPException
import shutil

UPLOAD_DIR = Path("uploads")
INSPECTION_DIR = UPLOAD_DIR / "inspections"
MAX_FILE_SIZE = 10 * 1024 * 1024
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".pdf", ".mp4", ".mov"}
ALLOWED_MIME_TYPES = {
    "image/jpeg", "image/jpg", "image/png", 
    "application/pdf", "video/mp4", "video/quicktime"
}

UPLOAD_DIR.mkdir(exist_ok=True)
INSPECTION_DIR.mkdir(exist_ok=True)


def validate_file(file: UploadFile) -> None:
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided")
    
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400, 
            detail=f"File type not allowed. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
        )
    
    if file.content_type and file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=400, 
            detail=f"MIME type not allowed: {file.content_type}"
        )


def generate_unique_filename(original_filename: str) -> str:
    file_ext = Path(original_filename).suffix.lower()
    unique_id = str(uuid.uuid4())
    return f"{unique_id}{file_ext}"


async def save_upload_file(file: UploadFile, directory: Path) -> dict:
    validate_file(file)
    
    unique_filename = generate_unique_filename(file.filename)
    file_path = directory / unique_filename
    
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        file_size = os.path.getsize(file_path)
        
        if file_size > MAX_FILE_SIZE:
            os.remove(file_path)
            raise HTTPException(
                status_code=400,
                detail=f"File too large. Maximum size is {MAX_FILE_SIZE / 1024 / 1024}MB"
            )
        
        return {
            "file_path": str(file_path),
            "file_name": unique_filename,
            "original_name": file.filename,
            "file_size": file_size,
            "mime_type": file.content_type
        }
    
    except Exception as e:
        if file_path.exists():
            os.remove(file_path)
        raise HTTPException(status_code=500, detail=f"File upload failed: {str(e)}")


async def save_inspection_photo(file: UploadFile) -> dict:
    return await save_upload_file(file, INSPECTION_DIR)


async def save_multiple_files(files: List[UploadFile], directory: Path) -> List[dict]:
    saved_files = []
    for file in files:
        try:
            file_info = await save_upload_file(file, directory)
            saved_files.append(file_info)
        except HTTPException:
            for saved_file in saved_files:
                if os.path.exists(saved_file["file_path"]):
                    os.remove(saved_file["file_path"])
            raise
    
    return saved_files


def delete_file(file_path: str) -> bool:
    try:
        path = Path(file_path)
        if path.exists() and path.is_file():
            os.remove(path)
            return True
        return False
    except Exception:
        return False
