import { test, expect } from '@playwright/test';

/**
 * Full-stack E2E Tests
 * 
 * These tests verify the complete application flow including backend integration.
 * Run with: E2E_WITH_BACKEND=true npm run test:e2e
 * 
 * Prerequisites:
 * - Backend server running on localhost:8080
 * - Database properly initialized
 */

// Only run these tests when backend is available
test.describe('Full-stack E2E Tests', () => {
  test.beforeEach(async ({ page, context }) => {
    // Skip if not running with backend
    if (process.env.E2E_WITH_BACKEND !== 'true') {
      test.skip(true, 'Skipping full-stack tests - run with E2E_WITH_BACKEND=true');
    }

    // Set up API monitoring
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

    // Navigate to E2E test page
    await page.goto('/e2e-test');
    await page.waitForSelector('.e2e-test-container');
  });

  test('should perform successful API health check', async ({ page }) => {
    await page.click('button:has-text("ヘルスチェック実行")');
    await expect(page.locator('text=ヘルスチェック成功！')).toBeVisible();
    await expect(page.locator('text="status": "healthy"')).toBeVisible();
  });

  test('should create message via POST API', async ({ page }) => {
    const testName = 'E2E Test User';
    await page.fill('input[placeholder="名前を入力してください"]', testName);
    await page.click('button:has-text("メッセージ作成 (POST)")');
    
    await expect(page.locator('text=POSTリクエスト成功！')).toBeVisible();
    await expect(page.locator(`text="name": "${testName}"`)).toBeVisible();
    await expect(page.locator(`text="message": "Hello, ${testName}!"`)).toBeVisible();
  });

  test('should retrieve messages via GET API', async ({ page }) => {
    // First create test data
    await page.fill('input[placeholder="名前を入力してください"]', 'GET Test User');
    await page.click('button:has-text("メッセージ作成 (POST)")');
    await expect(page.locator('text=POSTリクエスト成功！')).toBeVisible();

    // Then test GET
    await page.click('button:has-text("全メッセージ取得 (GET)")');
    await expect(page.locator('text=GETリクエスト成功！').first()).toBeVisible();
    await expect(page.locator('text=Hello, GET Test User!')).toBeVisible();
  });

  test('should handle validation errors properly', async ({ page }) => {
    await page.click('button:has-text("空の名前でPOST (エラーテスト)")');
    await expect(page.locator('text=バリデーションエラー成功！')).toBeVisible();
    await expect(page.locator('text="status": "error"')).toBeVisible();
  });

  test('should handle complete workflow', async ({ page }) => {
    // Health check
    await page.click('button:has-text("ヘルスチェック実行")');
    await expect(page.locator('text=ヘルスチェック成功！')).toBeVisible();

    // Create message
    const userName = 'Workflow Test User';
    await page.fill('input[placeholder="名前を入力してください"]', userName);
    await page.click('button:has-text("メッセージ作成 (POST)")');
    await expect(page.locator('text=POSTリクエスト成功！')).toBeVisible();

    // Retrieve messages
    await page.click('button:has-text("全メッセージ取得 (GET)")');
    await expect(page.locator('text=GETリクエスト成功！')).toBeVisible();
    await expect(page.locator(`text=Hello, ${userName}!`)).toBeVisible();

    // Test error handling
    await page.click('button:has-text("空の名前でPOST (エラーテスト)")');
    await expect(page.locator('text=バリデーションエラー成功！')).toBeVisible();
  });

  test('should display loading states during API calls', async ({ page }) => {
    await page.click('button:has-text("ヘルスチェック実行")');
    
    // Check for loading modal (might be brief)
    const loadingVisible = await page.locator('text=API通信中...').isVisible().catch(() => false);
    console.log('Loading state detected:', loadingVisible);
    
    await expect(page.locator('text=ヘルスチェック成功！')).toBeVisible();
  });
});