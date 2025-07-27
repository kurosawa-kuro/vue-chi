import { test, expect } from '@playwright/test';

test.describe('Frontend-Backend Integration', () => {
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

  test('should load the frontend application', async ({ page }) => {
    await page.goto('/');
    
    // Check if the page loads
    await expect(page).toHaveTitle(/Vue Starter App|Vite \+ Vue/);
    
    // Wait for Vue app to mount
    await page.waitForSelector('#app');
  });

  test('should make successful API call to backend health endpoint', async ({ page }) => {
    await page.goto('/');

    // Make API call and check response
    const response = await page.request.get('/api/health');
    expect(response.ok()).toBeTruthy();
    
    const healthData = await response.json();
    expect(healthData).toHaveProperty('status', 'healthy');
    expect(healthData).toHaveProperty('message');
    expect(healthData).toHaveProperty('timestamp');
  });

  test('should create hello world message via API', async ({ page }) => {
    await page.goto('/');

    const testData = {
      name: 'E2E Test User'
    };

    // Make POST request to create message
    const response = await page.request.post('/api/hello-world', {
      headers: {
        'Content-Type': 'application/json'
      },
      data: testData
    });

    expect(response.ok()).toBeTruthy();
    expect(response.status()).toBe(201);

    const responseData = await response.json();
    expect(responseData).toHaveProperty('status', 'success');
    expect(responseData).toHaveProperty('data');
    expect(responseData.data).toHaveProperty('name', testData.name);
    expect(responseData.data).toHaveProperty('message', `Hello, ${testData.name}!`);
    expect(responseData.data).toHaveProperty('id');
    expect(responseData.data).toHaveProperty('created_at');
  });

  test('should retrieve hello world messages via API', async ({ page }) => {
    await page.goto('/');

    // First create a message
    await page.request.post('/api/hello-world', {
      headers: {
        'Content-Type': 'application/json'
      },
      data: { name: 'E2E Test Retrieval' }
    });

    // Then retrieve all messages
    const response = await page.request.get('/api/hello-world/messages');
    expect(response.ok()).toBeTruthy();

    const responseData = await response.json();
    expect(responseData).toHaveProperty('status', 'success');
    expect(responseData).toHaveProperty('data');
    expect(Array.isArray(responseData.data)).toBeTruthy();
    expect(responseData.data.length).toBeGreaterThan(0);

    // Check that our test message is in the results
    const testMessage = responseData.data.find(msg => msg.name === 'E2E Test Retrieval');
    expect(testMessage).toBeDefined();
    expect(testMessage).toHaveProperty('message', 'Hello, E2E Test Retrieval!');
  });

  test('should handle API validation errors', async ({ page }) => {
    await page.goto('/');

    // Send invalid data (empty name)
    const response = await page.request.post('/api/hello-world', {
      headers: {
        'Content-Type': 'application/json'
      },
      data: { name: '' }
    });

    expect(response.status()).toBe(400);

    const responseData = await response.json();
    expect(responseData).toHaveProperty('status', 'error');
    expect(responseData).toHaveProperty('message');
  });

  test('should verify CORS headers on API responses', async ({ page }) => {
    await page.goto('/');

    const response = await page.request.get('/api/health');
    
    const headers = response.headers();
    expect(headers['access-control-allow-origin']).toBe('*');
    expect(headers['access-control-allow-methods']).toBe('GET, POST, PUT, DELETE, OPTIONS');
    expect(headers['access-control-allow-headers']).toBe('Content-Type, Authorization');
  });

  test('should handle network timeouts gracefully', async ({ page }) => {
    await page.goto('/');

    // Test with a reasonable timeout
    const response = await page.request.get('/api/health', {
      timeout: 5000
    });

    expect(response.ok()).toBeTruthy();
  });
});