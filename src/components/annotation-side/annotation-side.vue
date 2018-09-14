<template src="./annotation-side.html"></template>
<style lang="scss" src="./annotation-side.scss"></style>
<script>
/* global window MathJax */

const parser = new window.DOMParser()

const xmlescape = require('xml-escape')
const {pd} = require('pretty-data')
let xsltCollection = require('../../sbml-to-xhtml')(parser)
let sbml2elementDoc = xsltCollection[2].xslt

export default {
  name: 'AnnotationSide',
  props: ['xsltOptions'],
  data () {
    return {
      content: 'Nothing display',
      xsltProcessor: null
    }
  },
  mounted () {
    this.xsltProcessor = new XSLTProcessor()
    this.xsltProcessor.importStylesheet(sbml2elementDoc.firstElementChild)
    this.$root.$on('onOpenAnnotation', this.openAnnotation)
  },
  methods: {
    openAnnotation: function (id, content) {
      this.xsltProcessor.setParameter(null, 'elementId', id)
      try {
        let transformDoc = this.xsltProcessor.transformToFragment(content, document)
        this.content = this.documentToString(transformDoc)
        this.$nextTick(() => {
          MathJax.Hub.Queue(['Typeset', MathJax.Hub])
          this.prettifyAnnotation()
        })
      } catch (err) {
        console.log(err)
      }
    },
    prettifyAnnotation: function () {
      let annotation = document
        .getElementById('sidebarContent')
        .getElementsByClassName('sv-raw-xml')
      for (let i = 0; i < annotation.length; i++) {
        let data = annotation[i].innerHTML
        annotation[i].innerHTML = xmlescape(pd.xml(data))
      }
      window.PR.prettyPrint()
    },
    documentToString: (doc) => {
      let container = document
        .createElement('div')
        .appendChild(doc.firstElementChild)
      return container.outerHTML
    },
    onAnnotationClose: function () {
      this.$emit('closeAnnotation')
    }
  }
}
</script>
