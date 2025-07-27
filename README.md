# Vue-Chi

Vue.js + Go Chi フレームワークを使用したフルスタックWebアプリケーションです。フロントエンドにVue 3、バックエンドにGo + Chi REST APIを採用し、モダンな開発手法を実践するためのリファレンス実装を提供します。

## 🏗️ アーキテクチャ

- **フロントエンド**: Vue 3 + Vite + Tailwind CSS + Pinia
- **バックエンド**: Go + Chi Router + PostgreSQL
- **デプロイメント**: Docker Compose / Kubernetes対応
- **テスト**: Vitest + Playwright + Go testing

## 📋 必要条件

### 基本要件
- Node.js 18+
- Go 1.21.4+
- Docker 20.10+
- Docker Compose 2.0+

### Kubernetes環境（オプション）
- Ubuntu 18.04+ (WSL2も対応)
- Kind
- kubectl

## 🚀 クイックスタート

### Docker Composeでの起動（推奨）

```bash
# プロジェクトルートで実行
make docker

# バックグラウンドで起動
make docker-bg

# 停止
make docker-down
```

アクセス:
- **フロントエンド**: http://localhost:5173
- **バックエンドAPI**: http://localhost:8080/api
- **Swagger UI**: http://localhost:8080/swagger/index.html

## ☸️ Kubernetes環境での起動

### 前提条件のインストール

```bash
# Docker (まだインストールしていない場合)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
# ログアウト・ログインまたは newgrp docker

# Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### デプロイ

```bash
# プロジェクトルートから実行
./k8s/deploy.sh
```

このスクリプトは以下の処理を自動的に実行します：
1. 前提条件のチェック
2. Kindクラスターの作成
3. NGINX Ingress Controllerのインストール
4. DockerイメージのビルドとKindクラスターへのロード
5. Kubernetesマニフェストの適用

### アクセス設定

デプロイ完了後、ポートフォワーディングを設定してアクセスします：

```bash
# ポートフォワーディングの設定
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80 &
```

アクセス:
- **フロントエンド**: http://localhost:8080 (Host: vue-chi-staging.local)
- **バックエンドAPI**: http://localhost:8080/api (Host: vue-chi-staging.local)

**注意**: curlでテストする場合は `-H "Host: vue-chi-staging.local"` ヘッダーが必要です。

### 動作確認

```bash
# ポッド状態確認
kubectl get pods -n vue-chi-staging

# サービス確認
kubectl get services -n vue-chi-staging

# Ingress確認
kubectl get ingress -n vue-chi-staging

# ログ確認
kubectl logs -f deployment/backend-deployment -n vue-chi-staging
kubectl logs -f deployment/frontend-deployment -n vue-chi-staging
```

### クリーンアップ

```bash
./k8s/cleanup.sh
```

## 🛠️ 開発環境

### バックエンド開発

```bash
cd backend

# 環境変数の設定
make env-init ENV=development

# Docker Composeで起動（PostgreSQL含む）
make docker

# ローカル開発（ホットリロード）
make dev

# テスト実行
make test
```

詳細は [backend/README.md](backend/README.md) を参照してください。

### フロントエンド開発

```bash
cd frontend

# 依存関係のインストール
npm install

# 開発サーバー起動
npm run dev

# MSW有効で開発サーバー（バックエンドなしで開発可能）
npm run dev:mock

# テスト実行
npm run test

# E2Eテスト実行
npm run test:e2e
```

詳細は [frontend/README.md](frontend/README.md) を参照してください。

## 🧪 テスト

### 全体テスト

```bash
# 全テストを実行
make test

# E2Eテスト環境を起動
make e2e-up

# Playwright E2Eテストを実行
make e2e-test

# E2Eテスト環境を停止
make e2e-down
```

### テスト戦略

- **バックエンド**: Go testing + testify + httpexpect
- **フロントエンド単体**: Vitest + Vue Testing Library + MSW
- **E2Eテスト**: Playwright（MSWモック版 / フルスタック版）

## 📁 プロジェクト構造

```
vue-chi/
├── backend/              # Go + Chi REST API
│   ├── src/             # ソースコード
│   ├── db/              # データベース設定・マイグレーション
│   ├── docker/          # Docker設定
│   └── Makefile         # ビルド・テストコマンド
├── frontend/            # Vue 3 SPA
│   ├── src/             # ソースコード
│   ├── tests/           # テストファイル
│   └── package.json     # 依存関係・スクリプト
├── k8s/                 # Kubernetes設定
│   ├── deploy.sh        # デプロイスクリプト
│   ├── cleanup.sh       # クリーンアップスクリプト
│   ├── *.yaml          # Kubernetesマニフェスト
│   └── README.md        # 詳細なK8s手順
├── shared/              # 共通設定
│   └── docker/          # Docker Compose設定
└── Makefile             # プロジェクト全体のコマンド
```

## 🔧 トラブルシューティング

### Kubernetes環境

#### 「404 Not Found nginx」エラー
```bash
# ポートフォワーディングが必要です
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80 &
```

#### ポート競合
```bash
# ポート80/443が使用中の場合、他のサービスを停止
sudo systemctl stop apache2  # または nginx
```

#### Docker権限エラー
```bash
sudo usermod -aG docker $USER
# ログアウト・ログイン後に再実行
```

#### Ingress Controller起動失敗
```bash
# NGINX Ingress Controllerの状態確認
kubectl get pods -n ingress-nginx

# 再インストール
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### Docker Compose環境

```bash
# コンテナ状態確認
make docker-ps

# ログ確認
make docker-logs

# クリーンアップ
make docker-clean
```

## 📚 詳細ドキュメント

- **Kubernetes詳細手順**: [k8s/README.md](k8s/README.md)
- **バックエンド開発**: [backend/README.md](backend/README.md)
- **フロントエンド開発**: [frontend/README.md](frontend/README.md)

## 🤝 貢献

1. フォークを作成
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。
