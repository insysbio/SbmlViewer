export function updateContainerSize () {
  let newMargin = document.getElementById('optionsArea').clientHeight + 15 + 'px'
  document.getElementById('sidebarContent').style.top = newMargin
  document.getElementById('sidebarContent').style.height =
    document.documentElement.clientHeight - document.getElementById('optionsArea').clientHeight - 7 + 'px'
  document.getElementById('content').style.marginTop = newMargin
}
