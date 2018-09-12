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

const xmlescape = require('xml-escape')
const {pd} = require('pretty-data')
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
      if (!(isRefresh)) this.getListTransformationType(file)
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
          let oldCont = this.displayContent
          this.displayContent = this.getContent(file, isRefresh)
          if (this.displayContent !== oldCont) {
            this.updateMathjax()
            this.$root.$emit('closeAnnotation')
            this.$root.$emit('onClearErr')
            this.addEventListenerAnnotationElement()
            this.prettifyAnnotation()
          }
        }
      }, 100)
      this.doNextTick(() => {
        this.$root.$emit('stopSpin')
      })
    },
    getListTransformationType: function (file) {
      let SBMLElement = file.getElementsByTagName('sbml')
      let level = SBMLElement && SBMLElement[0] && SBMLElement[0].getAttribute('level')
      if (level) {
        this.transformationTypes = xsltCollection.filter((x) => x.level === level && x.name !== 'sbml2element')
      } else {
        this.transformationTypes = {}
        this.$root.$emit('onThrowError', 'Incorrect level')
      }
      this.doNextTick(() => {
        this.$root.$emit('onUpdateTransformationType')
      })
    },
    getTransformationType: function (xsltName) {
      let xsltDoc = this.transformationTypes.find(x => x.name === xsltName)
      return (xsltDoc && xsltDoc.xslt) || this.transformationTypes[0].xslt
    },
    getContent: function (file, isRefresh) {
      let doc = this.fileContent = file
      let transformDoc = this.transformDocument(this.modelXsltProcessor, doc)
      if (this.checkDocumentVersion(doc) && this.checkDocument(transformDoc)) {
        return this.documentToString(transformDoc)
      } else if (!(isRefresh)) {
        return '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>'
      }
    },
    toggleXslt: function (xslt) {
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
        console.log(xsltProcessor.transformToFragment(model, document))
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
    updateMathjax: function () {
      this.doNextTick(() => {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub])
      }, 500)
    },
    addEventListenerAnnotationElement: function () {
      this.$nextTick(() => {
        // set annotation in the right part
        let annotationElements = document.querySelectorAll('.sbml-id[id]')
        for (let i = 0; i < annotationElements.length; i++) {
          annotationElements[i].addEventListener('click', this.onClickAnnotation)
        }

        let annotationContainerArray = document.querySelectorAll('tr.sv-hidden')
        for (let i = 0; i < annotationContainerArray.length; i++) {
          let annotationContainer = annotationContainerArray[i]

          // set button for notes and annotation
          let button = document.createElement('i')
          button.setAttribute('class', 'sv-hide-button fa fa-info-circle')
          annotationContainer
            .previousSibling
            .firstElementChild
            .appendChild(button)

          button.addEventListener('click', () => {
            annotationContainer
              .classList
              .toggle('sv-hidden')
          })
        }
      })
    },
    prettifyAnnotation: function () {
      this.$nextTick(() => {
        let annotation = document.getElementsByClassName('sv-raw-xml')
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
      let container = document
        .createElement('div')
        .appendChild(doc.firstElementChild)
      return container.outerHTML
    },
    updateWindowSize: function () {
      let newMargin = document.getElementById('optionsArea').clientHeight + 15 + 'px'
      document.getElementById('sidebarContent').style.top = newMargin
      document.getElementById('sidebarContent').style.height = document.documentElement.clientHeight - document.getElementById('optionsArea').clientHeight - 7 + 'px'
      document.getElementById('content').style.marginTop = newMargin
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
html {}
html, head {
    height: 100%;
}
</style>
