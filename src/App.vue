<template>
  <div id="app">
  <ToolBar
    @onOpenFile="loadFile"
    @onChangeTT="toogleTT"
    v-bind:fileName = 'fileName'
    v-bind:currentTTName='currentTTName'
    v-bind:TTList='TTList'
    v-bind:ListTTParametrs='ListTTParametrs'
    v-bind:stateTTparametrs='stateTTparametrs'>
  </ToolBar>
  <ModelArea
    v-bind:displayContent='displayContent'
    v-bind:fileContent='fileContent'>
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
      TTList: {}, // list of xslt
      currentTTName: null, // name of current xslt
      currentTT: {}, // object of current xslt
      ListTTParametrs: {}, // list of xslt parameters
      stateTTparametrs: {}, // list of state(checked/unchecked) of xslt parameters
      fileUrl: null, // file url, save for read file by url after resfresh
      fileName: 'No file selected.', // file name, value of varible show beside input button
      displayContent: null, // content on display, save for transmit to model-area component
      fileContent: '' // file content, save for use after toggle xslt
    }
  },
  mounted () {
    if (this.checkFileByURL()) {
      this.$root.$emit('startSpin')
      this.$nextTick(() => {
        this.loadFile()
      })
    }
  },
  components: {
    ToolBar,
    ModelArea
  },
  methods: {
    /**
     * Save(isRefresh) or remove parameters and transmit file for readFile
     * * @param file - object of file, if file selected by button, or url of file, if it was transmit as query
     * * @param {bool} isRefresh - file refresh rate. It affects the saving of selected xslt and state of xslt parameters
     */
    loadFile: function (file, isRefresh = false) {
      // eliminate the conflict between the link and the selected file
      if (file && this.fileUrl) {
        this.fileUrl = null
      }

      this.$root.$emit('onClearErr')

      // save parameters for refresh and clean TT
      if (!(isRefresh)) {
        this.currentTTName = null
        this.stateTTparametrs = {}
      }
      this.currentTT = {}
      this.ListTTParametrs = {}

      this.readFile(file, (content) => {
        this.fileContent = content
        if (this.getTTData(content)) {
          this.setDataForDisplay(content)
        }
        this.$root.$emit('stopSpin')
      })
    },
    readFile: function (file, callback) {
      if (this.fileUrl) { // read file by URL
        this.fileName = this.fileUrl.match(/[_-\w]+.xml/)[0]

        let xmlhttp = new XMLHttpRequest()
        xmlhttp.open('GET', this.fileUrl, true)
        xmlhttp.send()
        xmlhttp.onreadystatechange = () => {
          if (xmlhttp.status === 200 && xmlhttp.readyState === 4) {
            callback(xmlhttp.responseXML)
          }

          if (xmlhttp.status !== 200 && xmlhttp.status !== 0) { this.$root.$emit('onThrowError', 'Can not read file') }
        }
      } else { // read file from COMPUTER
        this.fileName = file.name
        readXmlUpload(file, (err, result) => {
          if (err) {
            this.$root.$emit('onThrowError', 'Can not read file')
          }
          callback(result)
        })
      }
    },
    getTTData: function (fileContent) {
      this.TTList = this.getListTT(fileContent)
      if (Object.keys(this.TTList).length !== 0) {
        this.currentTT = this.getCurrentTT()
        this.ListTTParametrs = this.TTList.find((x) => x.name === this.currentTTName).parameters
        this.setStateTTParametrs()
        return true
      } else {
        this.$root.$emit('onThrowError', 'Incorrect level')
        return false
      }
    },
    setDataForDisplay: function (fileContent) {
      this.displayContent = null
      this.$nextTick(() => {
        let docDom = this.transformDocument(fileContent, this.currentTT.xslt)
        let docHTML = docDom && docDom.children[0].outerHTML

        if (docDom && checkCorrectTransfromDocument(docHTML)) {
          this.$root.$emit('resetContent')
          this.displayContent = docDom.children[0]
        } else {
          this.$root.$emit('onThrowError', 'Incorrect XML')
          return false
        }
      })
    },
    checkFileByURL: function () {
      let parameters = window.location.search.substring(1).split('&')
      if (parameters.length !== 0 && parameters[0] !== '') {
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
        // return this.TTList.find((x) => x.name === this.currentTTName) || this.TTList[0]
        let found = this.TTList.filter((x) => x.name === this.currentTTName)
        return found[0] || this.TTList[0]
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
        xsltProcessor.setParameter(null, 'transform', this.currentTT.name)
        xsltProcessor.setParameter(null, 'transform2', 'sbml' + this.currentTT.level + 'element')

        let params = this.ListTTParametrs
        for (let i in params) {
          let param = params[i]
          xsltProcessor.setParameter(null, param, this.stateTTparametrs[param])
        }

        return xsltProcessor.transformToFragment(transformDoc, document)
      } catch (err) { // if transfrom not success
        this.$root.$emit('onThrowError', 'Fail transform document')
        console.log(err)
        return null
      }
    },
    toogleTT: function (newTTName) {
      this.currentTTName = newTTName
      if (this.getTTData(this.fileContent)) {
        this.setDataForDisplay(this.fileContent)
      }
      this.$root.$emit('stopSpin')
    }
  },
  watch: {
    fileName: function (val, old) {
      document.title = val
    }
  }
}

// utilites
function checkCorrectTransfromDocument (html) {
  if (html.match(/= \?\?\?/) ||
      html.match(/This page contains the following errors/)
  ) {
    return false
  } else {
    return true
  }
}

</script>

<style src='w3css/w3.css'></style>
<style lang='scss' src='./assets/style/style.scss'></style>
<style lang='css' src='code-prettify/src/prettify.css'></style>
<style>
html, head {
    height: 100%;
    overflow: hidden;
}
</style>
