<template>
  <div id="app">
    <ToolBar @onUploadFile="updateFile"></ToolBar>
    <ModelArea v-bind:displayContent='displayContent'></ModelArea>
  </div>
</template>

<script>
import * as rawXsltStylesheet from './assets/xslt/sbml2table.xsl'
import ToolBar from './components/tool-bar/tool-bar.vue'
import ModelArea from './components/model-area/model-area.vue'
export default {
  name: 'App',
  data () {
    return {
      xsltOptions: {
        correctMathml: false,
        equationsOff: false,
        transform: 'sbml2table',
        transform2: 'sbml2element',
        useNames: false
      },
      displayContent: '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>',
      fileContent: null
    }
  },
  mounted () {
    this.xsltProcessorMainTable = this.applyXsltProcessor(new XSLTProcessor(), new DOMParser().parseFromString(rawXsltStylesheet, 'text/xml'), this.xsltOptions)
  },
  components: {
    ToolBar,
    ModelArea
  },
  methods: {
    updateFile: function (file) {
      let doc = this.transformDocument(this.xsltProcessorMainTable, new DOMParser().parseFromString(file.rawHTML, 'text/xml'))
      console.log(doc)
      if (this.checkDocumentVersion(doc) && this.checkDocument(doc)) {
        this.displayDocument(doc)
      }
    },
    applyXsltProcessor: (xsltProcessor, rawXsltStylesheet, xsltOptions) => {
      try {
        xsltProcessor.importStylesheet(rawXsltStylesheet)
        for (let opt in xsltOptions) {
          xsltProcessor.setParameter(null, opt, xsltOptions[opt])
        }
      } catch (err) {
      }
      return xsltProcessor
    },
    transformDocument: (xsltProcessor, model) => {
      try {
        return xsltProcessor.transformToFragment(model, document)
      } catch (err) { // if transfrom not success
      }
    },
    checkDocument: (doc) => {
      if (doc.firstElementChild.innerHTML.match(/= \?\?\?/) || doc.firstElementChild.innerHTML.match(/This page contains the following errors/)) { //
        console.log('Incorrect XML')
        return false
      } else {
        return true
      }
    },
    checkDocumentVersion: (doc) => {
      return true
      /*
          if (doc.firstElementChild.getAttribute('level') === '2') {
            return true
          } else {
            console.log('Incorrect level')
            return false
          } */
    },
    displayDocument: function (doc) {
      this.displayContent = this.documentToString(doc)
    },
    documentToString: (doc) => {
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
