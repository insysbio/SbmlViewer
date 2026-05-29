function renderDom (el, value) {
  while (el.firstChild) {
    el.removeChild(el.firstChild)
  }

  if (value) {
    el.appendChild(value)
  }
}

export default {
  mounted (el, binding) {
    renderDom(el, binding.value)
  },

  updated (el, binding) {
    renderDom(el, binding.value)
  }
}
