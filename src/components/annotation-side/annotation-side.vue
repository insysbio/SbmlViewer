<template src="./annotation-side.html"></template>
<style lang="scss" src="./annotation-side.scss"></style>
<script>
/* global window MathJax */
import { prettifyAnnotation } from '../../utilites/prettifyAnnotation'
const parser = new window.DOMParser()

let xsltCollection = require('../../sbml-to-xhtml')(parser)
let sbml2elementDoc = xsltCollection[2].xslt

export default {
  name: 'AnnotationSide',
  props: ['fileContent'],
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
    openAnnotation: function (id) {
      this.xsltProcessor.setParameter(null, 'elementId', id)
      try {
        let transformDoc = this.xsltProcessor.transformToFragment(this.fileContent, document)
        this.content = transformDoc.children[0].outerHTML
        this.$nextTick(() => {
          MathJax.Hub.Queue(['Typeset', MathJax.Hub])
          prettifyAnnotation('sidebarContent')
        })
      } catch (err) {
        console.log(err)
      }
    },
    onAnnotationClose: function () {
      this.$emit('closeAnnotation')
    }
  }
}
</script>
