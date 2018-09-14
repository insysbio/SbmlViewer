<template src="./tool-bar.html"></template>
<style lang="scss" src="./tool-bar.scss"></style>
<script>

export default {
  name: 'ToolBar',
  props: [
    'TTList',
    'ListTTParametrs',
    'stateTTparametrs',
    'currentTTName'
  ],
  data () {
    return {
      isSpin: false,
      fileName: 'No file choosen',
      file: null
    }
  },
  mounted () {
    this.$root.$on('startSpin', () => {
      this.isSpin = true
    })
    this.$root.$on('stopSpin', () => {
      this.isSpin = false
    })
    this.dragNdropInit()

    // this.$root.$on('onUpdateTransformationType', this.getDisplayOptions)
  },
  methods: {
    onRefresh: function () {
      this.$emit('onOpenFile', this.file, true)
    },
    onChooseFileInput: function (e) {
      e.preventDefault()
      // Запуск спина c $nextTick
      let file = document.getElementById('file').files[0]
      if (file) { // file can be emty, if user clicked on the button, but he not selected file
        this.file = file
        this.$emit('onOpenFile', file)
      }
    },
    toogleParam: function (paramName) {
      this.stateTTparametrs[paramName] = !this.stateTTparametrs[paramName]
    },
    onSelectTT: function () {
      this.$nextTick(() => {
        this.$emit('onChangeTT', this.currentTTName)
      })
    },
    dragNdropInit: function () {
      document.addEventListener('dragover', (event) => {
        event.preventDefault()
      })
      document.addEventListener('dragstart', (event) => {
        event.preventDefault()
      })
      document.addEventListener('drop', (event) => {
        event.preventDefault()
        let file = this.file = event.dataTransfer.files[0]
        this.$emit('onOpenFile', file)
      })
    }
  }
}
</script>
