<template src="./model-area.html"></template>
<style src="./model-area.scss"></style>
<script>
import AnnotationSide from '../annotation-side/annotation-side.vue'

export default {
  name: 'ModelArea',
  props: ['displayContent'],
  data () {
    return {
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
    AnnotationSide
  },
  mounted () {
  },
  methods: {
  }
}
</script>
