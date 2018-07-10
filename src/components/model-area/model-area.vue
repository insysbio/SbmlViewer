<template src="./model-area.html"></template>
<style lang="scss" src="./model-area.scss"></style>
<script>
import AnnotationSide from '../annotation-side/annotation-side.vue'
import ErrorContainer from '../error/error.vue'

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
    this.$root.$on('onOpenAnnotation', () => {
      console.log('detect')
      this.isSideOpen = true
    })
    this.$root.$on('closeAnnotation', () => {
      this.isSideOpen = false
    })
  },
  methods: {
  }
}
</script>
