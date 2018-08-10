<template>
  <div id="app">
  <ToolBar @onLoadFile="loadFile" @selectedXslt='toggleXslt' @onChangeXsltParam='rebuildXsltParams' v-bind:options='xsltOptions' v-bind:transformationTypes='transformationTypes'></ToolBar>
  <ModelArea v-bind:displayContent='displayContent'></ModelArea>
  </div>
</template>

<script>
/* global MathJax */

import ToolBar from './components/tool-bar/tool-bar.vue'
import ModelArea from './components/model-area/model-area.vue'
import 'code-prettify'
// import $ from 'jquery'
var xmlescape = require('xml-escape')
var pd = require('pretty-data').pd
const parser = new window.DOMParser()
const xsltCollection = require('./sbml-to-xhtml')(parser)

export default {
  name: 'App',
  data () {
    return {
      load: false,
      transformationTypes: {},
      xsltOptions: null,
      displayContent: '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>',
      fileContent: null,
      xsltStylesheet: '',
      xsltDoc: null,
      file: null
    }
  },
  mounted () {
    this.updateWindowSize()
    window.addEventListener('resize', this.updateWindowSize)
  },
  components: {
    ToolBar,
    ModelArea
  },
  methods: {
    loadFile: function (file, xsltName, isRefresh) {
      this.getListTransformationType(file, isRefresh)
      this.displayFile(file, xsltName, isRefresh)
    },
    displayFile: function (file, xsltName, isRefresh) {
      this.$root.$emit('startSpin')

      if (!(isRefresh)) this.displayContent = ''

      this.doNextTick(() => {
        this.xsltDoc = this.getTransformationType(xsltName)
        if (this.xsltDoc) {
          this.importStylesheetToXsltProcessor(
            new XSLTProcessor(),
            this.xsltDoc.firstElementChild
          )
          this.parseFile(file, isRefresh)
          this.addEventListenerAnnotationElement()
          this.prettifyAnnotation()
        }
      }, 100)
      this.doNextTick(() => {
        this.$root.$emit('stopSpin')
      })
    },
    getListTransformationType: function (file, isRefresh) {
      let SBMLElement = file.getElementsByTagName('sbml')
      let level = SBMLElement && SBMLElement[0] && SBMLElement[0].getAttribute('level')
      if (level) {
        this.transformationTypes = xsltCollection.filter((x) => x.level === level && x.name !== 'sbml2element')
      } else {
        this.transformationTypes = {}
        this.$root.$emit('onThrowError', 'Incorrect level')
      }
      this.doNextTick(() => {
        this.$root.$emit('onUpdateTransformationType', !(isRefresh))
      })
    },
    getTransformationType: function (xsltName) {
      let xsltDoc = this.transformationTypes.find(x => x.name === xsltName)
      return (xsltDoc && xsltDoc.xslt) || this.transformationTypes[0].xslt
    },
    parseFile: function (file, isRefresh) {
      let doc = this.fileContent = file
      let transformDoc = this.transformDocument(this.modelXsltProcessor, doc)
      if (this.checkDocumentVersion(doc) && this.checkDocument(transformDoc)) {
        this.displayDocument(transformDoc)
      } else if (!(isRefresh)) {
        this.displayContent = '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>'
      }
    },
    toggleXslt: function (xslt) {
      /* this.xsltDoc = xsltCollection.filter((x) => x.name === xslt)[0].xslt
      this.importStylesheetToXsltProcessor(
        new XSLTProcessor(),
        this.xsltDoc.firstElementChild
      ) */
      this.displayFile(this.fileContent, xslt)
    },
    rebuildXsltParams: function (transform, opt) {
      let params = opt
      params['transform'] = transform
      params['transform2'] = 'sbml2element'
      this.xsltOptions = params
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
      return true
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

        let annotationOpenElements = document.getElementsByClassName('sv-annotation-toogle-btn')
        for (let i = 0; i < annotationOpenElements.length; i++) {
          annotationOpenElements[i].addEventListener('click', (e) => {
            let annotationContainer = e.target.parentNode.parentNode.nextSibling
            let annotation = annotationContainer.firstElementChild
            annotationContainer.classList.toggle('sv-element-annotation-conatiner-height-open')
            annotation.classList.toggle('sv-element-annotation-height')
          })
        }
      })
    },
    prettifyAnnotation: function () {
      this.$nextTick(() => {
        let annotation = document.getElementsByClassName('sv-annotation-content')
        for (let i = 0; i < annotation.length; i++) {
          let data = annotation[i].innerHTML
          annotation[i].innerHTML = xmlescape(pd.xml(data))
        }
        window.PR.prettyPrint()
      })
    },
    onClickAnnotation: function (e) {
      this.$root.$emit('onOpenAnnotation', e.target.id, this.fileContent)
    },
    documentToString: function (doc) {
      let container = document.createElement('div').appendChild(doc.firstElementChild)
      return container.outerHTML
    },
    updateWindowSize: function () {
      var newHeight = document.documentElement.clientHeight - document.getElementById('optionsArea').clientHeight - 7 + 'px'
      document.getElementById('mainContent').style.height = newHeight
      document.getElementById('sideContent').style.height = newHeight
      document.getElementById('content').style.marginTop = document.getElementById('optionsArea').clientHeight + 15 + 'px'
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
<style lang='scss' src='code-prettify/src/prettify.css'></style>
<style>
html {
  overflow-y: hidden;
}
html, head {
  height: 100%;
}
</style>
