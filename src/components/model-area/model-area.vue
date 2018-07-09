<template src="./model-area.html"></template>
<style lang="scss" src="./model-area.scss"></style>
<script>
import AnnotationSide from '../annotation-side/annotation-side.vue'

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
    AnnotationSide
  },
  mounted () {
    this.$root.$on('onClickAnnotation', () => {
      this.isSideOpen = true
    })
  },
  methods: {
  }
}
</script>
