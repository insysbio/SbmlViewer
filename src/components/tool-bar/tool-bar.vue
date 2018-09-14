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
    // this.dragNdropInit()

    // this.$root.$on('onUpdateTransformationType', this.getDisplayOptions)
  },
  methods: {
    onRefresh: function () {
      this.$emit('onOpenFile', this.file, true)
      /* if (this.url) {
        this.uploadFileByUrl(true)
      }
      if (this.file) {
        this.uploadFileFromComputer(true)
      } */
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
    /*
    getDisplayOptions: function () {
      if (Object.keys(this.transformationTypes).length !== 0) {
        this.xslt = this.transformationTypes[0].name
        this.optionsDisplay = this.transformationTypes.find((x) => x.name === this.xslt).parameters
        this.optionsDisplay.forEach((item, i) => {
          this.options[item] = (this.options && this.options[item]) || false
        })
      } else {
        this.xslt = ''
        this.options = {}
        this.optionsDisplay = {}
      }
      this.$emit('onChangeXsltParam', this.xslt, this.options)
    },
    */
    checkGetUploadReq: function () {
      /* let parameters = window.location.search.substring(1).split('&')
      if (parameters.length !== 0) {
        return parameters[0]
      } else {
        return null
      } */
      return null
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
        // this.file = event.dataTransfer.files[0]
        // this.uploadFileFromComputer()
      })
    }
  }
}
</script>
