import Vue from 'vue'

Vue.directive('dom', {
  bind (el, binding, vnode) {
    if (el.children && el.children[0]) el.removeChild(el.children[0])
    if (binding.value) el.appendChild(binding.value)
  },
  update (el, binding, vnode) {
    if (el.children && el.children[0]) el.removeChild(el.children[0])
    if (binding.value) el.appendChild(binding.value)
  }
})
