<template>
  <div id="app">
  <ToolBar @onLoadFile="updateModel" @selectedXslt='updateXslt' @onUpdateXsltOptins='updateXsltOptions' v-bind:options='xsltOptions' v-bind:transformationTypes='transformationTypes'></ToolBar>
  <ModelArea v-bind:displayContent='displayContent'></ModelArea>
  </div>
</template>

<script>
/* global MathJax */

import ToolBar from './components/tool-bar/tool-bar.vue'
import ModelArea from './components/model-area/model-area.vue'
// import $ from 'jquery'
const parser = new window.DOMParser()
const xsltCollection = require('./sbml-to-xhtml')(parser)

export default {
  name: 'App',
  data () {
    return {
      load: false,
      transformationTypes: null,
      xsltOptions: null, /* {
        correctMathml: false,
        equationsOff: false,
        transform: 'sbml2table',
        transform2: 'sbml2element',
        useNames: false
      } */
      displayContent: '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>',
      fileContent: null,
      xsltStylesheet: '',
      xsltDoc: null,
      file: null
    }
  },
  mounted () {
    // this.changeModelXslt(this.xsltOptions.transform)
    this.updateWindowSize()
    window.addEventListener('resize', this.updateWindowSize)
  },
  components: {
    ToolBar,
    ModelArea
  },
  methods: {
    updateModel: function (file, isRefresh) {
      this.$root.$emit('startSpin')
      if (!(isRefresh)) this.displayContent = ''

      this.doNextTick(() => {
        this.getTransformationType(file)
        this.xsltDoc = this.transformationTypes[0].xslt
        this.applyXsltOptions()
        this.parseFile(file, isRefresh)
        this.addEventListenerAnnotationElement()
        this.$root.$emit('stopSpin')
      }, 100)
    },
    getTransformationType: function (file) {
      let SBMLElement = file.getElementsByTagName('sbml')
      let level = SBMLElement && SBMLElement[0] && SBMLElement[0].getAttribute('level')
      if (level) {
        this.transformationTypes = xsltCollection.filter((x) => x.level === level && x.name !== 'sbml2element')
        this.doNextTick(() => {
          this.$root.$emit('onUpdateTransformationType')
        })
      } else {
        this.$root.$emit('onThrowError', 'Incorrect level')
      }
    },
    updateWindowSize: function () {
      var newHeight = document.documentElement.clientHeight - document.getElementById('optionsArea').clientHeight - 7 + 'px'
      document.getElementById('mainContent').style.height = newHeight
      document.getElementById('sideContent').style.height = newHeight
      document.getElementById('content').style.marginTop = document.getElementById('optionsArea').clientHeight + 2 + 'px'
    },
    parseFile: function (file, isRefresh) {
      let doc = this.fileContent = file
      let transformDoc = this.transformDocument(this.modelXsltProcessor, doc)
      if (this.checkDocumentVersion(doc) && this.checkDocument(transformDoc)) {
        // console.log('ok')
        this.displayDocument(transformDoc)
      } else if (!(isRefresh)) {
        console.log('ups')
        this.displayContent = '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>'
      }
    },
    updateXslt: function (xslt, file) {
      this.changeModelXslt(xslt)
      this.updateModel(file)
    },
    changeModelXslt: function (xslt) {
      this.xsltDoc = xsltCollection.filter((x) => x.name === xslt)[0].xslt
      this.applyXsltOptions()
    },
    updateXsltOptions: function (transform, barOpt) {
      console.log(transform, barOpt)
      let options = barOpt
      options['transform'] = transform
      options['transform2'] = 'sbml2element'
      this.xsltOptions = options
    },
    applyXsltOptions: function () {
      this.importStylesheetToXsltProcessor(
        new XSLTProcessor(),
        this.xsltDoc.firstElementChild
      )
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
      if (doc.firstElementChild.innerHTML.match(/= \?\?\?/) || doc.firstElementChild.innerHTML.match(/This page contains the following errors/)
      ) { //
        this.$root.$emit('onThrowError', 'Incorrect XML')
        return false
      } else {
        return true
      }
    },
    checkDocumentVersion: function (doc) {
      try {
        let SBMLElement = doc.getElementsByTagName('sbml')
        if (SBMLElement[0].getAttribute('level') && SBMLElement[0].getAttribute('level') === '2') {
          return true
        } else {
          this.$root.$emit('onThrowError', 'Incorrect level')
          return false
        }
      } catch (err) {
        this.$root.$emit('onThrowError', 'Broken document')
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
      this.doNextTick(() => {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub])
      }, 500)
    },
    addEventListenerAnnotationElement: function () {
      this.$nextTick(() => {
        let annotationElements = document.getElementsByClassName('sv-id-target')
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
      return container.outerHTML
    },
    doNextTick: function (callback, time = 100) {
      setTimeout(() => {
        this.$nextTick(() => {
          callback()
        })
      }, time)
    }
  }
}
</script>

<style lang='scss' src='./assets/style/style.scss'></style>
<style>
html {
  overflow-x: hidden;
}
html, head {
  height: 100%;
}
</style>
