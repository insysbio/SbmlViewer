<template src="./model-area.html"></template>
<style lang="scss" src="./model-area.scss"></style>
<script>
/* global MathJax */

import AnnotationSide from '../annotation-side/annotation-side.vue'
import ErrorContainer from '../error/error.vue'
import 'code-prettify'

const xmlescape = require('xml-escape')
const {pd} = require('pretty-data')
export default {
  name: 'ModelArea',
  props: ['displayContent'],
  data () {
    return {
      isSideOpen: false,
      method: 'upload',
      xsltProcessorMainTable: null,
      xsltOptions: {
        correctMathml: false,
        equationsOff: false,
        transform: 'sbml2table',
        transform2: 'sbml2element',
        useNames: false
      }
    }
  },
  components: {
    AnnotationSide,
    ErrorContainer
  },
  mounted () {
    this.$root.$on('resetContent', () => {
      setTimeout(() => {
        this.$nextTick(() => {
          this.addEventListenerAnnotationElement()
          MathJax.Hub.Queue(['Typeset', MathJax.Hub])
          this.prettifyAnnotation()
        })
      }, 100)
    })
    this.$root.$on('closeAnnotation', () => {
      this.isSideOpen = false
    })
  },
  methods: {
    addEventListenerAnnotationElement: function () {
      this.$nextTick(() => {
        // set annotation in the right part
        let annotationElements = document.querySelectorAll('.sbml-id[id]')
        for (let i = 0; i < annotationElements.length; i++) {
          annotationElements[i].addEventListener('click', (e) => {
            this.isSideOpen = true
            this.$root.$emit('onOpenAnnotation', e.target.id, this.fileContent)
          })
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
      let annotation = document.getElementsByClassName('sv-raw-xml')
      for (let i = 0; i < annotation.length; i++) {
        let data = annotation[i].innerHTML
        annotation[i].innerHTML = xmlescape(pd.xml(data))
      }
      window.PR.prettyPrint()
    }
  }
}
</script>
