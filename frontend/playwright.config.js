import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright E2E Configuration
 * 
 * Two execution modes:
 * 1. Local Development (default): Uses MSW mocks for isolated frontend testing
 * 2. Full-stack Testing: Uses real backend when E2E_WITH_BACKEND=true
 */
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    ignoreHTTPSErrors: true,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    ...(process.env.CI ? [{
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    }] : []),
  ],

  // Frontend-only testing with MSW (default)
  webServer: process.env.E2E_WITH_BACKEND === 'true' ? undefined : {
    command: 'VITE_ENABLE_MSW=true npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});