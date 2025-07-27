<template>
  <div class="e2e-test-container p-6 max-w-2xl mx-auto">
    <h1 class="text-3xl font-bold mb-6 text-center">フロントエンド→バックエンド E2E テスト</h1>
    
    <!-- API Health Check -->
    <div class="mb-8 p-4 border border-gray-300 rounded-lg">
      <h2 class="text-xl font-semibold mb-4">📡 API ヘルスチェック</h2>
      <button 
        @click="checkHealth" 
        :disabled="loading"
        class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded mr-4"
      >
        ヘルスチェック実行
      </button>
      <div v-if="healthResult" class="mt-4 p-3 rounded" 
           :class="healthResult.success ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
        <strong>結果:</strong> {{ healthResult.message }}
        <pre v-if="healthResult.data" class="mt-2 text-sm">{{ JSON.stringify(healthResult.data, null, 2) }}</pre>
      </div>
    </div>

    <!-- POST Request Test -->
    <div class="mb-8 p-4 border border-gray-300 rounded-lg">
      <h2 class="text-xl font-semibold mb-4">📝 POST リクエストテスト</h2>
      <div class="mb-4">
        <label class="block text-sm font-medium mb-2">名前を入力:</label>
        <input 
          v-model="messageForm.name" 
          type="text" 
          placeholder="名前を入力してください"
          class="w-full p-2 border border-gray-300 rounded"
        >
      </div>
      <button 
        @click="createMessage" 
        :disabled="loading || !messageForm.name.trim()"
        class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded mr-4"
      >
        メッセージ作成 (POST)
      </button>
      <div v-if="postResult" class="mt-4 p-3 rounded" 
           :class="postResult.success ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
        <strong>POST結果:</strong> {{ postResult.message }}
        <pre v-if="postResult.data" class="mt-2 text-sm">{{ JSON.stringify(postResult.data, null, 2) }}</pre>
      </div>
    </div>

    <!-- GET Request Test -->
    <div class="mb-8 p-4 border border-gray-300 rounded-lg">
      <h2 class="text-xl font-semibold mb-4">📋 GET リクエストテスト</h2>
      <button 
        @click="getMessages" 
        :disabled="loading"
        class="bg-purple-500 hover:bg-purple-600 text-white px-4 py-2 rounded mr-4"
      >
        全メッセージ取得 (GET)
      </button>
      <div v-if="getResult" class="mt-4 p-3 rounded" 
           :class="getResult.success ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
        <strong>GET結果:</strong> {{ getResult.message }}
        <div v-if="getResult.data && getResult.data.length > 0" class="mt-2">
          <h4 class="font-semibold">メッセージ一覧:</h4>
          <div v-for="message in getResult.data.slice(0, 5)" :key="message.id" 
               class="bg-white p-2 my-1 rounded border">
            <strong>ID {{ message.id }}:</strong> {{ message.message }} 
            <small class="text-gray-600">({{ new Date(message.created_at).toLocaleString() }})</small>
          </div>
          <p v-if="getResult.data.length > 5" class="text-sm text-gray-600">
            ... 他 {{ getResult.data.length - 5 }} 件
          </p>
        </div>
      </div>
    </div>

    <!-- Validation Error Test -->
    <div class="mb-8 p-4 border border-gray-300 rounded-lg">
      <h2 class="text-xl font-semibold mb-4">❌ バリデーションエラーテスト</h2>
      <button 
        @click="testValidationError" 
        :disabled="loading"
        class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded mr-4"
      >
        空の名前でPOST (エラーテスト)
      </button>
      <div v-if="validationResult" class="mt-4 p-3 rounded" 
           :class="!validationResult.success ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
        <strong>バリデーション結果:</strong> {{ validationResult.message }}
        <pre v-if="validationResult.data" class="mt-2 text-sm">{{ JSON.stringify(validationResult.data, null, 2) }}</pre>
      </div>
    </div>

    <!-- Loading Indicator -->
    <div v-if="loading" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white p-4 rounded-lg">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-2"></div>
        <p>API通信中...</p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { apiClient } from '@/services/api'

export default {
  name: 'E2ETest',
  setup() {
    const loading = ref(false)
    const healthResult = ref(null)
    const postResult = ref(null)
    const getResult = ref(null)
    const validationResult = ref(null)
    const messageForm = ref({
      name: ''
    })

    const checkHealth = async () => {
      loading.value = true
      healthResult.value = null
      
      try {
        const response = await apiClient.get('/health')
        healthResult.value = {
          success: true,
          message: 'ヘルスチェック成功！バックエンドと正常に通信できています。',
          data: response.data
        }
      } catch (error) {
        healthResult.value = {
          success: false,
          message: 'ヘルスチェック失敗: ' + (error.response?.data?.message || error.message),
          data: error.response?.data
        }
      } finally {
        loading.value = false
      }
    }

    const createMessage = async () => {
      loading.value = true
      postResult.value = null
      
      try {
        const response = await apiClient.post('/hello-world', {
          name: messageForm.value.name.trim()
        })
        postResult.value = {
          success: true,
          message: 'POSTリクエスト成功！メッセージが作成されました。',
          data: response.data
        }
        messageForm.value.name = '' // フォームをクリア
      } catch (error) {
        postResult.value = {
          success: false,
          message: 'POSTリクエスト失敗: ' + (error.response?.data?.message || error.message),
          data: error.response?.data
        }
      } finally {
        loading.value = false
      }
    }

    const getMessages = async () => {
      loading.value = true
      getResult.value = null
      
      try {
        const response = await apiClient.get('/hello-world/messages')
        getResult.value = {
          success: true,
          message: `GETリクエスト成功！${response.data.data.length}件のメッセージを取得しました。`,
          data: response.data.data
        }
      } catch (error) {
        getResult.value = {
          success: false,
          message: 'GETリクエスト失敗: ' + (error.response?.data?.message || error.message),
          data: error.response?.data
        }
      } finally {
        loading.value = false
      }
    }

    const testValidationError = async () => {
      loading.value = true
      validationResult.value = null
      
      try {
        const response = await apiClient.post('/hello-world', {
          name: '' // 空の名前でバリデーションエラーを発生させる
        })
        validationResult.value = {
          success: true,
          message: '予期しない成功: バリデーションエラーが発生するはずでした',
          data: response.data
        }
      } catch (error) {
        validationResult.value = {
          success: false,
          message: 'バリデーションエラー成功！期待通りエラーが発生しました。',
          data: error.response?.data
        }
      } finally {
        loading.value = false
      }
    }

    return {
      loading,
      healthResult,
      postResult,
      getResult,
      validationResult,
      messageForm,
      checkHealth,
      createMessage,
      getMessages,
      testValidationError
    }
  }
}
</script>

<style scoped>
.e2e-test-container {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}
</style>