# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Android端末のタブレット内臓のカメラから金属インゴットの画像撮影をし、異常or正常の判断を出力するアプリ開発をするプロジェクトです。
バックエンドにはFastAPIを用いており、AWSのEC2上で動作させます。
FastAPIで用いる画像識別モデルは、AWSのS3からダウンロードしています。
フロントエンドはFlutterを用います。
推論はONNXモデルを用います。
AWS EC2のインスタンスタイプは、t3.microです。
判定履歴（画像・結果ログ）はデータベースやS3に保存し、アプリ内の任意のボタンを押すことで、判定履歴を参照できるようにしたいです。
データベースには、AWS RDS PostgreSQLを用います。
開発をしていく中で、曖昧な部分があれば、追加の質問をしろ。

## Architecture

- **Root level**: Python project managed by `uv` (Python 3.13, see `pyproject.toml` and `.python-version`).
- **`backend/`**: FastAPI service deployable via Docker to AWS EC2 (t3.micro).
  - `app.py` — メインAPI。起動時にS3からONNXモデルをダウンロードし、PostgreSQLテーブルを初期化する。
  - `database.py` — SQLAlchemy asyncモデル定義 (inspectionsテーブル)、DB接続管理。
  - エンドポイント: `/health`, `/anomaly-score` (推論), `/inspections` (履歴CRUD), `/inspections/{id}/image` (プリサインドURL)
  - 推論パイプライン: 画像前処理(PIL) → ONNX推論 → MSE, SSIM, Mahalanobis距離 → 正規化 → ensemble score → 閾値判定
  - 判定画像はS3 (`inspections/` prefix)、メタデータはPostgreSQLに保存。
- **`frontend/`**: Flutter (Dart) Android アプリ。パッケージ名: `com.toyota.ingot_inspector`
  - 4画面構成: カメラ撮影 → 判定結果 → 履歴一覧 → 設定
  - `lib/services/api_service.dart` — バックエンドAPIとの通信
  - `lib/config/api_config.dart` — APIサーバーURL管理 (SharedPreferences)

## Commands

### Backend (Docker)
```bash
cd backend
docker compose up --build        # API + PostgreSQL 起動
docker compose down              # 停止
```

### Frontend (Flutter)
```bash
cd frontend
flutter pub get                  # 依存取得
flutter run                      # 実機/エミュレータで実行
dart analyze lib/                # 静的解析
```

## Key Details

- バックエンドDockerfileはPython 3.11-slim (ルートの3.13とは異なる)。
- ONNXモデルセッションと統計量は `@lru_cache` でキャッシュ — プロセス起動時に1度だけ読み込み。
- デフォルト入力画像サイズは64x64。`/anomaly-score` の `image_size` パラメータで変更可能。
- `backend/.env.example` に全環境変数のテンプレートあり。本番ではRDS接続文字列を `DATABASE_URL` に設定。
- Flutter側のAPIサーバーURLはアプリ内の設定画面から変更可能 (デフォルト: EC2のIP)。
- コメント・docstringは日本語。
