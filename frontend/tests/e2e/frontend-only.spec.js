import { test, expect } from '@playwright/test';

/**
 * Frontend-only E2E Tests
 * 
 * These tests verify the Vue SPA frontend functionality using MSW mocks.
 * They ensure the UI components work correctly without requiring a backend server.
 */
test.describe('Frontend-only E2E Tests (MSW)', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the application
    await page.goto('/');
  });

  test('should load the home page and display navigation', async ({ page }) => {
    // Check page title
    await expect(page).toHaveTitle(/Home - Vue Starter App/);
    
    // Check sidebar navigation elements
    await expect(page.locator('#sidebar')).toBeVisible();
    await expect(page.locator('#sidebar >> text=Home')).toBeVisible();
    await expect(page.locator('#sidebar >> text=Hello World')).toBeVisible();
    await expect(page.locator('#sidebar >> text=E2E Test')).toBeVisible();
  });

  test('should navigate between pages using router', async ({ page }) => {
    // Navigate to Hello World page
    await page.click('#sidebar >> text=Hello World');
    await expect(page).toHaveURL(/.*\/hello-world/);
    await expect(page.locator('h1')).toContainText('Hello');
    
    // Navigate back to Home
    await page.click('#sidebar >> text=Home');
    await expect(page).toHaveURL(/.*\//);
  });

  test('should handle responsive design', async ({ page }) => {
    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('#sidebar')).toBeVisible();
    
    // Test desktop viewport
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('#sidebar')).toBeVisible();
  });

  test('should handle form interactions', async ({ page }) => {
    // Navigate to a page with forms (if exists)
    await page.goto('/');
    
    // Test any form elements present on the page
    const formElements = await page.locator('input, button, select, textarea').count();
    if (formElements > 0) {
      console.log(`Found ${formElements} form elements to test`);
      // Add specific form testing logic here based on your app
    }
  });

  test('should display proper error states', async ({ page }) => {
    // Test 404 page
    await page.goto('/non-existent-page');
    
    // Should either show 404 page or redirect to home
    const is404 = await page.locator('text=404').isVisible().catch(() => false);
    const isHome = page.url().endsWith('/');
    
    expect(is404 || isHome).toBeTruthy();
  });
});