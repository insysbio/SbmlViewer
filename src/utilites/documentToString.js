export function documentToString (doc) {
  let container = document
    .createElement('div')
    .appendChild(doc.firstElementChild)
  return container.outerHTML
}
