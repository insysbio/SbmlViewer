<template src="./annotation-side.html"></template>
<style lang="scss" src="./annotation-side.scss"></style>
<script>
/* global window MathJax */

const parser = new window.DOMParser()

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
        let docs = this.xsltProcessor.transformToDocument(content)
        let dContent = this.documentToString(docs)
        this.content = dContent
        setTimeout(() => {
          this.$nextTick(() => {
            MathJax.Hub.Queue(['Typeset', MathJax.Hub])
          })
        }, 500)
      } catch (err) {

      }
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
