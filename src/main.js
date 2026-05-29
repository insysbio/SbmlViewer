import { createApp } from 'vue'
import App from './App'
import domDirective from './directives/dom'
import eventBus from './event-bus'

const app = createApp(App)

app.directive('dom', domDirective)
app.use(eventBus)
app.mount('#app')
