const xmlescape = require('xml-escape')
const {pd} = require('pretty-data')

export function prettifyAnnotation (idContainer) {
  let annotation = document
    .getElementById(idContainer)
    .getElementsByClassName('sv-raw-xml')
  for (let i = 0; i < annotation.length; i++) {
    let data = annotation[i].innerHTML
    annotation[i].innerHTML = xmlescape(pd.xml(data))
  }
  window.PR.prettyPrint()
}
