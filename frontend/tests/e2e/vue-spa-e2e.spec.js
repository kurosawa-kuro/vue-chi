import { test, expect } from '@playwright/test';

test.describe('Vue SPA E2E Test Page', () => {
  test.beforeEach(async ({ page }) => {
    // Enable request/response logging
    page.on('request', request => {
      if (request.url().includes('/api/')) {
        console.log(`→ ${request.method()} ${request.url()}`);
      }
    });
    
    page.on('response', response => {
      if (response.url().includes('/api/')) {
        console.log(`← ${response.status()} ${response.url()}`);
      }
    });
  });

  test('should navigate to E2E test page and load components', async ({ page }) => {
    await page.goto('/e2e-test');
    
    // Check if the E2E test page loads
    await expect(page).toHaveTitle(/E2E Test - Vue Starter App/);
    
    // Wait for Vue app to mount and components to load
    await page.waitForSelector('.e2e-test-container');
    
    // Check main sections are present
    await expect(page.locator('h1')).toContainText('フロントエンド→バックエンド E2E テスト');
    await expect(page.locator('text=APIヘルスチェック')).toBeVisible();
    await expect(page.locator('text=POSTリクエストテスト')).toBeVisible();
    await expect(page.locator('text=GETリクエストテスト')).toBeVisible();
    await expect(page.locator('text=バリデーションエラーテスト')).toBeVisible();
  });

  test('should successfully perform API health check', async ({ page }) => {
    await page.goto('/e2e-test');
    await page.waitForSelector('.e2e-test-container');

    // Click health check button
    await page.click('button:has-text("ヘルスチェック実行")');
    
    // Wait for API response and check success message
    await expect(page.locator('text=ヘルスチェック成功！バックエンドと正常に通信できています。')).toBeVisible();
    
    // Check that API response data is displayed
    await expect(page.locator('text="status": "healthy"')).toBeVisible();
  });

  test('should successfully create a message via POST request', async ({ page }) => {
    await page.goto('/e2e-test');
    await page.waitForSelector('.e2e-test-container');

    // Fill in the name input
    const testName = 'Playwright E2E User';
    await page.fill('input[placeholder="名前を入力してください"]', testName);
    
    // Click create message button
    await page.click('button:has-text("メッセージ作成 (POST)")');
    
    // Wait for API response and check success message
    await expect(page.locator('text=POSTリクエスト成功！メッセージが作成されました。')).toBeVisible();
    
    // Check that the created message data is displayed
    await expect(page.locator(`text="name": "${testName}"`)).toBeVisible();
    await expect(page.locator(`text="message": "Hello, ${testName}!"`)).toBeVisible();
    
    // Verify input field is cleared after successful submission
    await expect(page.locator('input[placeholder="名前を入力してください"]')).toHaveValue('');
  });

  test('should retrieve messages via GET request', async ({ page }) => {
    await page.goto('/e2e-test');
    await page.waitForSelector('.e2e-test-container');

    // First create a message to ensure we have data
    await page.fill('input[placeholder="名前を入力してください"]', 'Test Data User');
    await page.click('button:has-text("メッセージ作成 (POST)")');
    await expect(page.locator('text=POSTリクエスト成功！')).toBeVisible();

    // Now test GET request
    await page.click('button:has-text("全メッセージ取得 (GET)")');
    
    // Wait for API response and check success message
    await expect(page.locator('text=GETリクエスト成功！').first()).toBeVisible();
    
    // Check that message list is displayed
    await expect(page.locator('text=メッセージ一覧:')).toBeVisible();
    await expect(page.locator('text=Hello, Test Data User!')).toBeVisible();
  });

  test('should handle validation error correctly', async ({ page }) => {
    await page.goto('/e2e-test');
    await page.waitForSelector('.e2e-test-container');

    // Click validation error test button (sends empty name)
    await page.click('button:has-text("空の名前でPOST (エラーテスト)")');
    
    // Wait for API response and check error handling
    await expect(page.locator('text=バリデーションエラー成功！期待通りエラーが発生しました。')).toBeVisible();
    
    // Check that error response data is displayed
    await expect(page.locator('text="status": "error"')).toBeVisible();
  });

  test('should handle multiple API operations in sequence', async ({ page }) => {
    await page.goto('/e2e-test');
    await page.waitForSelector('.e2e-test-container');

    // 1. Health check
    await page.click('button:has-text("ヘルスチェック実行")');
    await expect(page.locator('text=ヘルスチェック成功！')).toBeVisible();

    // 2. Create message
    await page.fill('input[placeholder="名前を入力してください"]', 'Sequential Test User');
    await page.click('button:has-text("メッセージ作成 (POST)")');
    await expect(page.locator('text=POSTリクエスト成功！')).toBeVisible();

    // 3. Get messages
    await page.click('button:has-text("全メッセージ取得 (GET)")');
    await expect(page.locator('text=GETリクエスト成功！')).toBeVisible();

    // 4. Test validation error
    await page.click('button:has-text("空の名前でPOST (エラーテスト)")');
    await expect(page.locator('text=バリデーションエラー成功！')).toBeVisible();

    // Verify all test sections have results
    await expect(page.locator('text="status": "healthy"')).toBeVisible(); // Health check
    await expect(page.locator('text="name": "Sequential Test User"')).toBeVisible(); // POST
    await expect(page.locator('text=Hello, Sequential Test User!')).toBeVisible(); // GET
    await expect(page.locator('text="status": "error"')).toBeVisible(); // Validation error
  });

  test('should show loading states during API calls', async ({ page }) => {
    await page.goto('/e2e-test');
    await page.waitForSelector('.e2e-test-container');

    // Start API call and check for loading state
    await page.click('button:has-text("ヘルスチェック実行")');
    
    // Loading state should appear briefly
    const loadingModal = page.locator('text=API通信中...');
    
    // Wait for the API call to complete
    await expect(page.locator('text=ヘルスチェック成功！')).toBeVisible();
  });
});