export function updateContainerSize () {
  console.log('size')
  let newMargin = document.getElementById('tool-bar').clientHeight + 15 + 'px'
  document.getElementById('content').style.marginTop = newMargin

  let sideBar = document.getElementById('sidebarContent')
  if (sideBar) {
    sideBar.style.top = parseInt(newMargin) + 10 + 'px'
    sideBar.style.height =
      document.documentElement.clientHeight - document.getElementById('optionsArea').clientHeight - 7 + 'px'
  }
  let mainContent = document.getElementById('mainContent')
  if (mainContent) {
    mainContent.style.height =
        document.documentElement.clientHeight - document.getElementById('tool-bar').clientHeight - 14 + 'px'
  }
}
