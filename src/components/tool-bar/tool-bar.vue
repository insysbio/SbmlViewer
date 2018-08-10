<template src="./tool-bar.html"></template>
<style lang="scss" src="./tool-bar.scss"></style>
<script>

import { readXmlUpload } from '../../utilites/readXmlUpload'
import $ from 'jquery'

export default {
  name: 'ToolBar',
  props: [
    'transformationTypes'
  ],
  data () {
    return {
      isSpin: false,
      fileName: 'No file choosen',
      optionsDisplay: {},
      xslt: null,
      file: null,
      options: {}
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
    this.url = this.checkGetUploadReq()
    if (this.url) {
      this.uploadFileByUrl()
    }

    this.$root.$on('onUpdateTransformationType', this.getDisplayOptions)
  },
  methods: {
    refresh: function () {
      if (this.url) {
        this.uploadFileByUrl(true)
      }
      if (this.file) {
        this.uploadFileFromComputer(true)
      }
    },
    onChooseFile: function (e) {
      e.preventDefault()
      if (document.getElementById('file').files[0]) {
        this.file = document.getElementById('file').files[0]
        this.url = null
        this.uploadFileFromComputer()
      }
    },
    uploadFileFromComputer: function (isRefresh = false) {
      this.updateFileName(this.file.name)
      readXmlUpload(this.file, (err, result) => {
        if (err) throw err
        this.$emit('onLoadFile', result, this.xslt, isRefresh)
      })
    },
    updateFileName: function (name) {
      this.fileName = name
      $('title').html(name)
    },
    changeOption: function (optName) {
      this.options[optName] = !this.options[optName]
    },
    onSelectXslt: function () {
      this.options.transform = this.xslt
      this.getDisplayOptions()
      this.$emit('selectedXslt', this.xslt)
    },
    getDisplayOptions: function (isNewListTransformationType = false) {
      if (Object.keys(this.transformationTypes).length !== 0) {
        if (!(this.xslt) || isNewListTransformationType) this.xslt = this.transformationTypes[0].name
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
    checkGetUploadReq: function () {
      let parameters = window.location.search.substring(1).split('&')
      if (parameters.length !== 0) {
        return parameters[0]
      } else {
        return null
      }
    },
    uploadFileByUrl: function (isRefresh = false) {
      this.file = null
      this.updateFileName(this.url.match(/[_-\w]+.xml/)[0])
      $.ajax({
        url: this.url,
        success: (result) => {
          let fileContent = result
          this.fileContent = fileContent
          this.$emit('onLoadFile', fileContent, this.xslt, isRefresh)
        }
      })
    },
    dragNdropInit: function () {
      $(document).on('dragover', function (e) {
        e.preventDefault()
      })
      $(document).on('dragstart', function (e) {
        e.preventDefault()
      })
      $(document).on('drop', (e) => {
        e.preventDefault()
        this.file = e.originalEvent.dataTransfer.files[0]
        this.uploadFileFromComputer()
      })
    }
  }
}
</script>
