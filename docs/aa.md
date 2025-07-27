 権限問題解決手順

  1. 権限エラーの原因

  # Docker実行時に作成されたファイルの所有者がrootになっている
  ls -la frontend/test-results/
  ls -la frontend/playwright-report/

  2. 手動解決コマンド

  # プロジェクトルートで実行
  cd /home/wsl/dev/my-study/vue-chi

  # 1. test-resultsディレクトリの権限修正
  sudo chown -R $USER:$USER frontend/test-results/ 2>/dev/null || true
  sudo chmod -R 755 frontend/test-results/ 2>/dev/null || true

  # 2. playwright-reportディレクトリの権限修正  
  sudo chown -R $USER:$USER frontend/playwright-report/ 2>/dev/null || true
  sudo chmod -R 755 frontend/playwright-report/ 2>/dev/null || true

  # 3. 完全削除して再作成
  rm -rf frontend/test-results frontend/playwright-report
  mkdir -p frontend/test-results frontend/playwright-report

  # 4. node_modulesの権限も確認
  sudo chown -R $USER:$USER frontend/node_modules/ 2>/dev/null || true

  3. Playwright実行手順

  # 権限修正後、以下の順序で実行

  # Step 1: E2E環境確認
  docker compose -f shared/docker/docker-compose.e2e.yml ps

  # Step 2: サービス稼働確認
  curl http://localhost:5173/e2e-test
  curl http://localhost:8080/api/health

  # Step 3: Playwrightテスト実行
  cd frontend
  npm run test:e2e -- tests/e2e/vue-spa-e2e.spec.js --project=chromium --workers=1

  # Step 4: レポート確認
  npx playwright show-report

  4. 権限問題回避の代替方法

  # 方法A: 一時ディレクトリ使用
  export PLAYWRIGHT_HTML_REPORT=/tmp/playwright-report
  export PLAYWRIGHT_TEST_RESULTS=/tmp/test-results

  # 方法B: Docker実行時にユーザー指定
  docker run --rm --user $(id -u):$(id -g) \
    -v /home/wsl/dev/my-study/vue-chi/frontend:/app \
    -w /app \
    mcr.microsoft.com/playwright:v1.54.1-jammy \
    npx playwright test

  5. 完全なE2Eテスト実行コマンド

  # 権限修正 + E2E実行の完全手順
  cd /home/wsl/dev/my-study/vue-chi

  # 権限修正
  sudo chown -R $USER:$USER frontend/
  rm -rf frontend/test-results frontend/playwright-report

  # E2E環境起動（まだの場合）
  docker compose -f shared/docker/docker-compose.e2e.yml up -d

  # テスト実行
  cd frontend
  npx playwright test tests/e2e/vue-spa-e2e.spec.js --project=chromium --reporter=line

  # 結果確認
  echo "テスト完了 - ログでPOST通信成功を確認してください"

  6. 期待される成功ログ

  → GET http://localhost:8080/api/health
  ← 200 http://localhost:8080/api/health
  → POST http://localhost:8080/api/hello-world
  ← 201 http://localhost:8080/api/hello-world

  権限修正後、上記の手順でPlaywright E2Eテストが正常実行され、フロントエンド→バックエンドPOST通信の成功が確認できます。

╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ >                                                                                                                                                                                                                                                                                                                                 │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  ⏵⏵ auto-accept edits on (shift+tab to cycle)                                                                                                                                                                                                                                                                                    ◯
                                                                                                                                                                                                                                                                                                Context left until auto-compact: 4%




