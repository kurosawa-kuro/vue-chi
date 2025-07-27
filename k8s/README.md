# Vue-Chi Kubernetes Staging Environment

このディレクトリには、UbuntuでKind (Kubernetes in Docker) を使用したステージング環境の設定ファイルが含まれています。

## 前提条件

- Ubuntu 18.04+ (WSL2も対応)
- Docker
- Kind
- kubectl

### インストール手順

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

## ファイル構成

```
k8s/
├── kind-config.yaml           # Kindクラスター設定
├── namespace.yaml             # 名前空間定義
├── postgres-init-configmap.yaml # PostgreSQL初期化SQL
├── postgres-deployment.yaml   # PostgreSQLデプロイメント
├── backend-deployment.yaml    # バックエンドデプロイメント
├── frontend-deployment.yaml   # フロントエンドデプロイメント
├── ingress.yaml              # Ingressルール
├── deploy.sh                 # デプロイスクリプト
├── cleanup.sh                # クリーンアップスクリプト
└── README.md                 # このファイル
```

## クイックスタート

### 1. デプロイ

```bash
# プロジェクトルートから実行
cd /home/wsl/dev/my-study/vue-chi
./k8s/deploy.sh
```

このスクリプトは以下の処理を自動的に実行します：

1. 前提条件のチェック
2. Kindクラスターの作成
3. NGINX Ingress Controllerのインストール
4. DockerイメージのビルドとKindクラスターへのロード
5. Kubernetesマニフェストの適用
6. hostsファイルの設定

### 2. アクセス

デプロイ完了後、以下の手順でアクセスしてください：

1. **ポートフォワーディングの設定**
   ```bash
   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80 &
   ```

2. **hostsファイルの設定**
   
   **WSL環境の場合（Windowsブラウザからアクセスする場合）**:
   ```powershell
   # PowerShellを管理者として実行
   Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 vue-chi-staging.local"
   ```
   
   **Linux環境の場合**:
   ```bash
   echo "127.0.0.1 vue-chi-staging.local" | sudo tee -a /etc/hosts
   ```

3. **アクセス**
   - **フロントエンド**: http://vue-chi-staging.local:8080
   - **バックエンドAPI**: http://vue-chi-staging.local:8080/api

**注意**: `localhost:8080`ではアクセスできません。必ず`vue-chi-staging.local:8080`を使用してください。

### 3. クリーンアップ

```bash
./k8s/cleanup.sh
```

## 手動操作

### 個別コマンド

```bash
# クラスター作成
kind create cluster --config k8s/kind-config.yaml --name vue-chi-staging

# イメージビルド
cd backend && docker build -f docker/Dockerfile -t vue-chi-backend:staging .
cd ../frontend && docker build -f docker/Dockerfile -t vue-chi-frontend:staging .

# イメージロード
kind load docker-image vue-chi-backend:staging --name vue-chi-staging
kind load docker-image vue-chi-frontend:staging --name vue-chi-staging

# マニフェスト適用
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-init-configmap.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/ingress.yaml

# NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### 状態確認

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
kubectl logs -f deployment/postgres-deployment -n vue-chi-staging
```

## アーキテクチャ

### クラスター構成

- **Control Plane**: 1ノード
- **Worker Nodes**: 2ノード
- **Ingress**: NGINX Ingress Controller

### アプリケーション構成

- **Frontend**: Vue 3 SPA (2レプリカ)
- **Backend**: Go + Chi API (2レプリカ)
- **Database**: PostgreSQL (1レプリカ、永続化ストレージ付き)

### ネットワーク

- **Ingress**: vue-chi-staging.local
  - `/` → Frontend Service (port 80)
  - `/api` → Backend Service (port 8080)
- **Internal Communication**: ClusterIP Services

### ストレージ

- **PostgreSQL**: 10GiのPersistentVolumeClaimを使用

## トラブルシューティング

### よくある問題

1. **「404 Not Found nginx」エラー**
   ```bash
   # ポートフォワーディングが必要です
   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80 &
   ```
   
   **WSL環境でWindowsブラウザを使用する場合**:
   - Windowsの hosts ファイル (`C:\Windows\System32\drivers\etc\hosts`) に以下を追加:
     ```
     127.0.0.1 vue-chi-staging.local
     ```
   - PowerShell（管理者）で実行:
     ```powershell
     Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 vue-chi-staging.local"
     ```
   
   **Linux環境の場合**:
   ```bash
   # hostsファイルエントリが正しいか確認
   grep vue-chi-staging.local /etc/hosts
   ```
   
   **重要**: `vue-chi-staging.local:8080` でアクセス（localhost:8080ではない）

2. **ポート競合**
   ```bash
   # ポート80/443が使用中の場合、他のサービスを停止
   sudo systemctl stop apache2  # または nginx
   ```

3. **Docker権限エラー**
   ```bash
   sudo usermod -aG docker $USER
   # ログアウト・ログイン後に再実行
   ```

4. **Ingress Controller起動失敗**
   ```bash
   # NGINX Ingress Controllerの状態確認
   kubectl get pods -n ingress-nginx
   
   # 再インストール
   kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
   ```

5. **イメージプル失敗**
   ```bash
   # イメージがKindクラスターに正しくロードされているか確認
   docker exec -it vue-chi-staging-control-plane crictl images
   ```

6. **ポートフォワーディングを停止したい場合**
   ```bash
   # バックグラウンドで実行中のポートフォワーディングを停止
   pkill -f "kubectl port-forward"
   ```

### ログとデバッグ

```bash
# 全ポッドのイベント確認
kubectl get events -n vue-chi-staging --sort-by='.lastTimestamp'

# 特定のポッドの詳細情報
kubectl describe pod <pod-name> -n vue-chi-staging

# Ingress Controllerのログ
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## カスタマイズ

### 環境変数の変更

`backend-deployment.yaml`や`postgres-deployment.yaml`の環境変数セクションを編集してください。

### レプリカ数の変更

各デプロイメントファイルの`replicas`フィールドを変更してください。

### リソース制限の調整

各デプロイメントファイルの`resources`セクションを調整してください。

## セキュリティ考慮事項

- PostgreSQLのパスワードはKubernetes Secretで管理
- 本番環境では、より強固なパスワードとシークレット管理を実装してください
- Ingressでは基本的なCORS設定のみ実装、本番環境では適切なセキュリティポリシーを設定してください