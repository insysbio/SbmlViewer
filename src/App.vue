<template>
  <div id="app">
  <ToolBar @onLoadFile="updateModel" @selectedXslt='updateXslt' v-bind:options='xsltOptions'></ToolBar>
  <ModelArea v-bind:displayContent='displayContent'></ModelArea>
  </div>
</template>

<script>
/* global MathJax */

import ToolBar from './components/tool-bar/tool-bar.vue'
import ModelArea from './components/model-area/model-area.vue'
export default {
  name: 'App',
  data () {
    return {
      load: false,
      xsltOptions: {
        correctMathml: false,
        equationsOff: false,
        transform: 'sbml2table',
        transform2: 'sbml2element',
        useNames: false
      },
      displayContent: '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>',
      fileContent: null,
      xsltStylesheet: '',
      file: null
    }
  },
  mounted () {
    this.changeModelXslt(this.xsltOptions.transform)
  },
  components: {
    ToolBar,
    ModelArea
  },
  methods: {
    updateModel: function (file) {
      this.$root.$emit('startSpin')
      setTimeout(() => {
        this.$nextTick(() => {
          this.updateXsltOptions()
          this.parseFile(file)
          this.addEventListenerAnnotationElement()
          this.$root.$emit('stopSpin')
        })
      }, 100)
    },
    updateXsltOptions: function () {
      this.importStylesheetToXsltProcessor(new XSLTProcessor(), new DOMParser().parseFromString(this.xsltStylesheet, 'text/xml'), this.xsltOptions)
    },
    parseFile: function (file) {
      let doc = this.fileContent = file
      let transformDoc = this.transformDocument(this.modelXsltProcessor, doc)
      if (this.checkDocumentVersion(doc) && this.checkDocument(transformDoc)) {
        this.displayDocument(transformDoc)
      }
    },
    changeModelXslt: function (xslt) {
      this.xsltStylesheet = require('./assets/xslt/' + xslt + '.xsl')
      this.updateXsltOptions()
    },
    updateXslt: function (xslt, file) {
      this.changeModelXslt(xslt)
      this.updateModel(file)
    },
    importStylesheetToXsltProcessor: function (xsltProcessor, xsltStylesheet) {
      try {
        xsltProcessor.importStylesheet(xsltStylesheet)
        for (let opt in this.xsltOptions) {
          xsltProcessor.setParameter(null, opt, this.xsltOptions[opt])
        }
      } catch (err) {
        this.$root.$emit('onThrowError', 'Fail import stylesheet')
      }
      this.modelXsltProcessor = xsltProcessor
    },
    transformDocument: function (xsltProcessor, model) {
      try {
        return xsltProcessor.transformToFragment(model, document)
      } catch (err) { // if transfrom not success
        this.$root.$emit('onThrowError', 'Fail transform document')
      }
    },
    checkDocument: function (doc) {
      if (doc.firstElementChild.innerHTML.match(/= \?\?\?/) || doc.firstElementChild.innerHTML.match(/This page contains the following errors/)) { //
        this.$root.$emit('onThrowError', 'Incorrect XML')
        return false
      } else {
        return true
      }
    },
    checkDocumentVersion: function (doc) {
      console.log(doc)
      if (doc.firstElementChild.getAttribute('level') === '2') {
        return true
      } else {
        this.$root.$emit('onThrowError', 'Incorrect level')
        return false
      }
    },
    displayDocument: function (doc) {
      this.displayContent = this.documentToString(doc)
      this.updateMathjax()
      this.$root.$emit('closeAnnotation')
      this.$root.$emit('onClearErr')
    },
    updateMathjax: function () {
      setTimeout(() => {
        this.$nextTick(() => {
          MathJax.Hub.Queue(['Typeset', MathJax.Hub])
        })
      }, 500)
    },
    addEventListenerAnnotationElement: function () {
      this.$nextTick(() => {
        let annotationElements = document.getElementsByClassName('annotationTarget')
        for (let i = 0; i < annotationElements.length; i++) {
          annotationElements[i].addEventListener('click', this.onClickAnnotation)
        }
      })
    },
    onClickAnnotation: function (e) {
      this.$root.$emit('onOpenAnnotation', e.target.id, this.fileContent)
    },
    documentToString: function (doc) {
      let container = document.createElement('div').appendChild(doc.firstElementChild)
      return container.innerHTML
    }
  }
}
</script>

<style>
html {
  overflow-x: hidden;
}
</style>
