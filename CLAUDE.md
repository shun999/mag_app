# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Android端末のタブレット内臓のカメラから金属インゴットの画像撮影をし、異常or正常の判断を出力するアプリ開発をするプロジェクトです。
バックエンドにはFastAPIを用いており、AWSのEC2上で動作させます。
FastAPIで用いる画像識別モデルは、AWSのS3からダウンロードしています。
フロントエンドはFlutterを用います。

## Architecture

- **Root level**: Python project managed by `uv` (Python 3.13, see `pyproject.toml` and `.python-version`). 
- **`backend/`**: Self-contained FastAPI service deployable via Docker to AWS EC2.
  - `app.py` — Single-file API. On startup (lifespan), downloads ONNX model and stats from S3. Exposes `/health` (GET) and `/anomaly-score` (POST, accepts image upload).
  - Anomaly detection pipeline: image preprocessing (PIL) → ONNX inference (onnxruntime) → compute MSE, SSIM (scipy gaussian_filter), Mahalanobis distance → normalize using pre-computed stats → ensemble score → threshold comparison.
  - Model and detection stats (latent_mean, inv_cov, mse/ssim/mahal mean/std, ensemble_threshold) are loaded from `.npz` file.

## Key Details

- The backend Dockerfile uses Python 3.11-slim (distinct from the root project's Python 3.13).
- ONNX model session and detection stats are cached via `@lru_cache` — loaded once per process.
- Default input image size is 64x64; the `/anomaly-score` endpoint accepts an `image_size` query parameter to override.
- All code comments and docstrings are in Japanese.
