<template src="./annotation-side.html"></template>
<style src="./annotation-side.scss"></style>
<script>
import * as xsltStylesheet from '../../assets/xslt/sbml2element.xsl'

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
    this.xsltProcessor.importStylesheet(new DOMParser().parseFromString(xsltStylesheet, 'text/xml'))
    this.$root.$on('onClickAnnotation', this.openAnnotation)
  },
  methods: {
    openAnnotation: function (id, content) {
      console.log('open')
      console.log(id, content)
      this.xsltProcessor.setParameter(null, 'elementId', id)
      try {
        console.log('try')
        let docs = this.xsltProcessor.transformToDocument(content)
        let dContent = this.documentToString(docs)
        console.log(docs)
        console.log(dContent)
        this.content = dContent
        // console.log()
      } catch (err) {

      }
    },
    documentToString: (doc) => {
      let container = document.createElement('div').appendChild(doc.firstElementChild)
      return container.innerHTML
    }
  }
}
/*

  clearErrMess()

  console.log('Display information about element...')
  // element, that was clicked
  var id = event.target.id, sideContent = document.getElementById('sideContent')

  console.log(' Clear display...')
  while (sideContent.childNodes[0]) {
    sideContent.removeChild(sideContent.childNodes[0])
  }
  console.log('   Success')

  console.log(' Transform data to document...')
  xsltProcessor2.setParameter(null, 'elementId', id)
  try {
    var resultDocument = xsltProcessor2.transformToDocument(curFile['content'])
    sideContent.appendChild(resultDocument.firstElementChild)
    console.log('   Success\n Success display')// Transform
  } catch (err) {
    console.error(' Err:', err)
    var p = document.createElement('p')
    p.classList.add('class', 'w3-text-red', 'w3-center', 'w3-large', 'w3-padding')
    p.appendChild(document.createTextNode('Cannot display element'))
    sideContent.appendChild(p)
  }

  // show block
  document.getElementById('sideInformBlock').style.display = 'block'
  document.getElementById('sideInformBlock').classList.add('w3-col', 'l3', 'm3', 's3', 'w3-animate-right')
  document.getElementById('mainContent').classList.add('l9', 'm9', 's9')

  // update equations
  MathJax.Hub.Queue(['Typeset', MathJax.Hub]) */
</script>
