export function updateContainerSize () {
  let newMargin = document.getElementById('tool-bar').clientHeight + 15 + 'px'
  document.getElementById('content').style.marginTop = parseInt(newMargin) - 13 + 'px'

  let sideBar = document.getElementById('sidebarContent')
  if (sideBar) {
    sideBar.style.top = parseInt(newMargin) - 13 + 'px'
    sideBar.style.height =
      document.documentElement.clientHeight - document.getElementById('tool-bar').clientHeight + 'px'
  }
  let mainContent = document.getElementById('mainContent')
  if (mainContent) {
    mainContent.style.height =
        document.documentElement.clientHeight - document.getElementById('tool-bar').clientHeight + 'px'
  }
}
