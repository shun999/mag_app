"""
データベース接続とモデル定義 (PostgreSQL + asyncpg)
"""

import os
import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, Column, DateTime, Float, Integer, String
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql+asyncpg://postgres:postgres@db:5432/ingot_inspection",
)

engine = create_async_engine(DATABASE_URL, echo=False)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


class Base(DeclarativeBase):
    pass


class Inspection(Base):
    __tablename__ = "inspections"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    image_s3_key = Column(String, nullable=False)
    filename = Column(String, nullable=False)
    ensemble_score = Column(Float, nullable=False)
    is_anomaly = Column(Boolean, nullable=False)
    threshold = Column(Float, nullable=False)
    reconstruction_error = Column(Float, nullable=False)
    ssim_score = Column(Float, nullable=False)
    mahalanobis_distance = Column(Float, nullable=False)
    inference_time_ms = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))


async def init_db():
    """テーブルが存在しない場合に作成する。"""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def get_db():
    """リクエストごとのDBセッションを提供する。"""
    async with async_session() as session:
        yield session
