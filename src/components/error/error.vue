<template src="./error.html"></template>
<style src="./error.scss"></style>
<script>
export default {
  name: 'ErrorContainer',
  data () {
    return {
      errorMessage: '',
      errorDictionary: require('./error.json')
    }
  },
  mounted () {
    this.$root.$on('onThrowError', (errStatus) => {
      this.displayErr(this.errorDictionary[errStatus].message)
    })
    this.$root.$on('onClearErr', this.clear)
  },
  methods: {
    displayErr: function (errMess) {
      this.errorMessage = errMess
    },
    clear: function () {
      this.errorMessage = ''
    }
  }
}
</script>
