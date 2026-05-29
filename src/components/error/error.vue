<template src="./error.html"></template>
<style lang="scss" src="./error.scss"></style>
<script>
export default {
  name: 'ErrorContainer',
  data () {
    return {
      errorMessage: null,
      errorDictionary: require('./error.json')
    }
  },
  mounted () {
    this.$bus.on('onThrowError', (errStatus) => {
      this.displayErr(this.errorDictionary[errStatus].message)
    })
    this.$bus.on('onClearErr', this.clear)
  },
  methods: {
    displayErr: function (errMess) {
      this.errorMessage = errMess
    },
    clear: function () {
      this.errorMessage = null
    }
  }
}
</script>
