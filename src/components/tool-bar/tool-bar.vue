<template src="./tool-bar.html"></template>
<style lang="scss" src="./tool-bar.scss"></style>
<script>

import { version } from '../../../package'

export default {
  name: 'ToolBar',
  props: [
    'TTList',
    'ListTTParametrs',
    'stateTTparametrs',
    'currentTTName',
    'fileName'
  ],
  data () {
    return {
      isSpin: false,
      file: null,
      version: version,
      homepage: 'https://sv.insysbio.com'
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

    document.title = this.fileName
  },
  methods: {
    onRefresh: function () {
      this.isSpin = true
      this.$nextTick(() => {
        this.$emit('onOpenFile', this.file, true)
      })
    },
    onChooseFileInput: function (e) {
      e.preventDefault()
      // Запуск спина c $nextTick
      let file = document.getElementById('file').files[0]
      if (file) { // file can be emty, if user clicked on the button, but he not selected file
        this.file = file
        this.isSpin = true
        this.$nextTick(() => {
          this.$emit('onOpenFile', file)
        })
      }
    },
    toogleParam: function (paramName) {
      this.stateTTparametrs[paramName] = !this.stateTTparametrs[paramName]
    },
    onSelectTT: function () {
      this.isSpin = true
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
