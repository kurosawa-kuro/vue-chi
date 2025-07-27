import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '@/pages/HomePage.vue'
import HelloWorldPage from '@/pages/HelloWorldPage.vue'
import E2ETest from '@/components/E2ETest.vue'
import NotFoundPage from '@/pages/NotFoundPage.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomePage,
    meta: { title: 'Home' }
  },
  {
    path: '/hello-world',
    name: 'HelloWorld',
    component: HelloWorldPage,
    meta: { title: 'Hello World' }
  },
  {
    path: '/e2e-test',
    name: 'E2ETest',
    component: E2ETest,
    meta: { title: 'E2E Test' }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: NotFoundPage,
    meta: { title: 'Page Not Found' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// ナビゲーションガード
router.beforeEach((to, from, next) => {
  // ページタイトルの設定
  document.title = to.meta.title ? `${to.meta.title} - Vue Starter App` : 'Vue Starter App'
  next()
})

export default router 