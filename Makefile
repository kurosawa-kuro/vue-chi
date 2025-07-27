# Vue-Chi Project - Main Makefile
#
# このMakefileはプロジェクト全体の操作を提供します。
# backend/frontend固有の操作は各ディレクトリのMakefileを参照してください。

SHARED_DIR := $(shell pwd)/shared
export SHARED_DIR

# 共通Dockerコマンドをインクルード
include $(SHARED_DIR)/docker/Makefile.docker

.PHONY: help all backend frontend test clean

help:
	@echo "🚀 Vue-Chi Project - 利用可能なコマンド:"
	@echo ""
	@echo "【全体操作】"
	@echo "  make all             - 全サービスをビルド"
	@echo "  make test            - 全テストを実行"
	@echo "  make clean           - ビルド成果物をクリーンアップ"
	@echo ""
	@echo "【Docker操作】"
	@echo "  make docker          - Docker Composeで全サービス起動"
	@echo "  make docker-bg       - Docker Composeでバックグラウンド起動"
	@echo "  make docker-down     - Docker Composeで停止"
	@echo "  make docker-frontend - フロントエンドコンテナのみ起動"
	@echo "  make docker-backend  - バックエンドコンテナのみ起動"
	@echo "  make docker-logs     - Docker Composeのログを表示"
	@echo "  make docker-ps       - 実行中のコンテナ一覧"
	@echo "  make docker-clean    - Dockerのクリーンアップ"
	@echo ""
	@echo "【個別操作】"
	@echo "  make backend         - backendディレクトリでhelpを表示"
	@echo "  make frontend        - frontendディレクトリでhelpを表示"
	@echo ""
	@echo "詳細は各ディレクトリのMakefileを参照してください。"

all:
	@echo "🔨 全サービスをビルド中..."
	@cd backend && $(MAKE) build
	@cd frontend && npm run build

backend:
	@cd backend && $(MAKE) help

frontend:
	@cd frontend && npm run help || echo "frontendディレクトリのpackage.jsonを確認してください"

test:
	@echo "🧪 全テストを実行中..."
	@cd backend && $(MAKE) test
	@cd frontend && npm test

clean:
	@echo "🧹 クリーンアップ中..."
	@cd backend && $(MAKE) clean || true
	@cd frontend && rm -rf dist node_modules || true
	@echo "✨ クリーンアップ完了"