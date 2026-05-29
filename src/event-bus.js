const listeners = {}

const eventBus = {
  on (event, handler) {
    if (!listeners[event]) {
      listeners[event] = []
    }
    listeners[event].push(handler)
  },

  off (event, handler) {
    if (!listeners[event]) {
      return
    }
    listeners[event] = listeners[event].filter((listener) => listener !== handler)
  },

  emit (event, ...args) {
    if (!listeners[event]) {
      return
    }
    listeners[event].forEach((handler) => handler(...args))
  }
}

export default {
  install (app) {
    app.config.globalProperties.$bus = eventBus
  }
}
