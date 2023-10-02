import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import VueClipboard from 'vue3-clipboard'
const app = createApp(App)

app.use(router)
app.use(VueClipboard)
app.mount('#app')
