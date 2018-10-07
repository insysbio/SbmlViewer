<template src="./model-area.html"></template>
<style lang="scss" src="./model-area.scss"></style>
<script>
/* global MathJax */
import AnnotationSide from '../annotation-side/annotation-side.vue'
import ErrorContainer from '../error/error.vue'
import Vue from 'vue'

import 'code-prettify'
import { updateContainerSize } from '../../utilites/updateContainerSize'
import { prettifyAnnotation } from '../../utilites/prettifyAnnotation'

export default {
  name: 'ModelArea',
  props: [
    'displayContent',
    'fileContent'
  ],
  data () {
    return {
      isSideOpen: false
    }
  },
  components: {
    AnnotationSide,
    ErrorContainer
  },
  mounted () {
    this.$root.$on('resetContent', () => {
      this.isSideOpen = false
      // add addons after render component
      setTimeout(() => {
        this.$nextTick(() => {
          this.addEventListenerAnnotationElement()
          MathJax.Hub.Queue(['Typeset', MathJax.Hub])
          prettifyAnnotation('mainContent')
        })
      }, 100)
    })

    updateContainerSize()
    window.addEventListener('resize', updateContainerSize)
  },
  methods: {
    addEventListenerAnnotationElement: function () {
      this.$nextTick(() => {
        // set annotation in the right part
        let annotationElements = document.querySelectorAll('.sbml-id[id]')
        for (let i = 0; i < annotationElements.length; i++) {
          annotationElements[i].addEventListener('click', (e) => {
            this.isSideOpen = true
            let contentNode = document
              .getElementById('mainContent')
              .firstElementChild

            this.$root.$emit('onOpenAnnotation', e.target.id, contentNode)
          })
        }

        let annotationContainerArray = document.querySelectorAll('tr.sv-hidden')
        for (let i = 0; i < annotationContainerArray.length; i++) {
          let annotationContainer = annotationContainerArray[i]

          // set button for notes and annotation
          let button = document.createElement('i')
          button.setAttribute('class', 'sv-hide-button sv-info-symbol')
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
    }
  },
  watch: {
    displayContent: function () {
      this.isSideOpen = false
    }
  }
}
</script>
