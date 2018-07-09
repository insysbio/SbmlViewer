<template src="./error.html"></template>
<style src="./error.scss"></style>
<script>
export default {
  name: 'ErrorContainer',
  data () {
    return {
      errorMessage: ''
    }
  },
  mounted () {
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
