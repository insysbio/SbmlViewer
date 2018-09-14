<template>
  <div id="app">
  <ToolBar
    @onOpenFile="loadFile"
    @onChangeTT="toogleTT"
    v-bind:currentTTName='currentTTName'
    v-bind:TTList='TTList'
    v-bind:ListTTParametrs='ListTTParametrs'
    v-bind:stateTTparametrs='stateTTparametrs'>
  </ToolBar>
  <ModelArea
    v-bind:displayContent='displayContent'>
  </ModelArea>
  </div>
</template>

<script>

import ToolBar from './components/tool-bar/tool-bar.vue'
import ModelArea from './components/model-area/model-area.vue'

import { readXmlUpload } from './utilites/readXmlUpload'

const parser = new window.DOMParser()
const xsltCollection = require('./sbml-to-xhtml')(parser)

export default {
  name: 'App',
  data () {
    return {
      load: false,
      TTList: {},
      currentTTName: null,
      currentTT: {},
      ListTTParametrs: {},
      stateTTparametrs: {},
      file: null,
      fileUrl: null,
      displayContent: '<div class="w3-container w3-center w3-large w3-text-grey w3-margin">Drug\'n\'drop SBML file here.</div>'

    }
  },
  mounted () {
    // this.updateWindowSize()
    // window.addEventListener('resize', this.updateWindowSize)

    if (this.checkFileByURL()) {
      this.loadFile()
    }
  },
  components: {
    ToolBar,
    ModelArea
  },
  methods: {
    loadFile: function (file, isRefresh = false) {
      if (file && this.fileUrl) {
        this.fileUrl = null
      }

      if (!(isRefresh)) {
        this.currentTTName = null
        this.stateTTparametrs = {}
      }
      this.currentTT = {}
      this.ListTTParametrs = {}

      this.readFile(file, (content) => {
        this.fileContent = content
        this.getDataForDisplay(content, isRefresh)
      })
      // if (!(isRefresh)) this.getListTransformationType(file)
      // this.displayFile(file, xsltName, isRefresh)
    },
    readFile: function (file, callback) {
      if (this.fileUrl) {
        this.getFileByUrl(null, callback)
      } else {
        this.getFileFromComputer(file, callback)
      }
    },
    getFileByUrl: function (isRefresh = false, callback) {
      this.file = null
      // this.updateFileName(this.url.match(/[_-\w]+.xml/)[0])

      let xmlhttp = new XMLHttpRequest()
      xmlhttp.onreadystatechange = () => {
        if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
          callback(xmlhttp.responseXML, isRefresh)
        }
      }
      xmlhttp.open('GET', this.fileUrl, true)
      xmlhttp.send()
    },
    getFileFromComputer: function (file, callback) {
      readXmlUpload(file, (err, result) => {
        if (err) throw err
        callback(result)
      })
    },
    getDataForDisplay: function (fileContent = this.fileContent, isRefresh = false) {
      this.TTList = this.getListTT(fileContent)
      this.currentTT = this.getCurrentTT()
      if (Object.keys(this.TTList).length !== 0) {
        this.ListTTParametrs = this.TTList.find((x) => x.name === this.currentTTName).parameters
      }
      this.setStateTTParametrs()
      let doc = this.transformDocument(fileContent, this.currentTT.xslt)
      let content = this.documentToString(doc)
      if (content !== this.displayContent) {
        this.$root.$emit('resetContent')
      }
      this.displayContent = content
    },
    checkFileByURL: function () {
      let parameters = window.location.search.substring(1).split('&')
      if (parameters.length !== 0) {
        this.fileUrl = parameters[0]
        return true
      } else {
        this.fileUrl = null
        return false
      }
    },
    getListTT: function (fileContent) {
      let SBMLElement = fileContent.getElementsByTagName('sbml')
      let level = SBMLElement && SBMLElement[0] && SBMLElement[0].getAttribute('level')
      if (level) {
        return xsltCollection.filter((x) => x.level === level && x.name !== 'sbml2element' && x.name !== 'sbml3element')
      } else {
        this.$root.$emit('onThrowError', 'Incorrect level')
        return {}
      }
    },
    getCurrentTT: function () {
      if (this.currentTTName) {
        return this.TTList.find((x) => x.name === this.currentTTName) || this.TTList[0]
      } else {
        this.currentTTName = this.TTList[0].name
        return this.TTList[0]
      }
    },
    setStateTTParametrs: function () {
      if (Object.keys(this.ListTTParametrs).length !== 0) {
        this.ListTTParametrs.forEach((item, i) => {
          this.stateTTparametrs[item] = (this.stateTTparametrs && this.stateTTparametrs[item]) || false
        })
      } else {
        this.stateTTparametrs = {}
      }
    },
    transformDocument: function (transformDoc, xsltStylesheet) {
      try {
        let xsltProcessor = new XSLTProcessor()
        xsltProcessor.importStylesheet(xsltStylesheet)
        // set parameters transfrom
        let params = this.ListTTParametrs
        params['transform'] = this.currentTT.name
        params['transform2'] = 'sbml' + this.currentTT.level + 'element'
        for (let i in params) {
          let param = params[i]
          xsltProcessor.setParameter(null, param, this.stateTTparametrs[param])
        }

        return xsltProcessor.transformToFragment(transformDoc, document)
      } catch (err) { // if transfrom not success
        this.$root.$emit('onThrowError', 'Fail transform document')
        console.log(err)
      }
    },
    toogleTT: function (newTTName) {
      this.currentTTName = newTTName
      this.getDataForDisplay()
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
