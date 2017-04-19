window.onload = function() {
  var link = document.createElement("a");
  link.setAttribute("href","http://sbmlviewer.insilicobio.ru/"+dist+"viewer.xhtml");
  link.innerHTML = "Try demo online";
  
  document.getElementById("tryDemo").appendChild(link);
  var liList = document.getElementsByTagName("ul")[1].getElementsByTagName("li");
  for(var i = 0; i < liList.length; i++) {
    var Link = liList[i].getElementsByTagName("a")[0].getAttribute("href");
    var newLink = "http://sbmlviewer.insilicobio.ru/"+dist+"viewer.xhtml"+Link.match(/(\?[\w\:\/\.\-]+)/)[0];
    liList[i].getElementsByTagName("a")[0].setAttribute("href",newLink);
  }
}