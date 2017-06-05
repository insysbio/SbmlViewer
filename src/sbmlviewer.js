 var options = {
    transform: "sbml2table",
    transform2: "sbml2element",
    filepath: "",
    method: "URL"
  };
  
  var waysDisplayPage = [
    "sbml2table",
    "sbml2math"
  ];
  
  var optionsDisplay = [
    "useNames",
    "correctMathml",
    "equationsOff"
  ];
  
function readXml(x, callback) { // return xml object as readed from file 
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET", x, false);       
  xmlhttp.onload = function(){
    callback(this.responseXML);
  };
       
  xmlhttp.error = function(){
    document.getElementById("errorMess").innerHTML = "Cannot upload the file.";
  };
       
  xmlhttp.send();
  }
    
var xsltProcessor1 = new XSLTProcessor(); //processor for 1st xslt
var xsltProcessor2 = new XSLTProcessor(); //processor for 2d xslt
var modelDoc=null;
var file = null;
    
window.onload = function() {      
  readXml("xslt/"+options["transform"]+".xsl", function(xsl1) {
    xsltProcessor1.importStylesheet(xsl1);
  
    xsltProcessor1.setParameter(null, "useNames", options["useNames"]);
    xsltProcessor1.setParameter(null, "correctMathml", options["correctMathml"]);
    xsltProcessor1.setParameter(null, "equationsOff", options["equationsOff"]);
  });

  readXml("xslt/"+options["transform2"]+".xsl", function(xsl2) {
    xsltProcessor2.importStylesheet(xsl2);
    xsltProcessor2.setParameter(null, "useNames", options["useNames"]);
    xsltProcessor2.setParameter(null, "correctMathml", options["correctMathml"]);
  });   
  
  var newHeight = document.documentElement.clientHeight - document.getElementById("optionsArea").clientHeight + "px";
  document.getElementById("mainContent").style.height = newHeight;
  document.getElementById("sideInformBlock").style.height = newHeight;
  /*Listen event*/
  
  /** Listen click on button "file", validate it and run reading */
  document.getElementById("file").addEventListener("change", function(event) {
    file = document.getElementById("file").files[0];
    validateUploadFile(file.name, 'upload');
  }, false);


  document.addEventListener("drop", function(event) {
    event.preventDefault();
    event.stopPropagation();
    file = event.dataTransfer.files[0];
      validateUploadFile(file.name, 'upload');
  });

  document.addEventListener("dragstart", function() {
    event.preventDefault();
  }); 

  document.addEventListener("dragover", function(event) {
    event.preventDefault();
  });

  document.getElementById("refresh").addEventListener("click", function() {     
    if ((file) || (options["filepath"])) {
      loadModeToPage();
    }
    else {
     document.getElementById("errorMess").innerHTML = "Cannot upload the file.";
    }  
  });  

  var select = document.getElementsByTagName("select")[0];
  waysDisplayPage.forEach(function(item) {
    var option = document.createElement("option");
    option.innerHTML = item;
    select.appendChild(option);   
  });

  select.addEventListener("change", function() {
    options["transform"] = this.value;
    readXml("xslt/"+options["transform"]+".xsl", function(xsl1) {
    xsltProcessor1.importStylesheet(xsl1);
    
    xsltProcessor1.setParameter(null, "useNames", options["useNames"]);
    xsltProcessor1.setParameter(null, "correctMathml", options["correctMathml"]);
    xsltProcessor1.setParameter(null, "equationsOff", options["equationsOff"]);
    });
  }, true);
       
  var listBtn = document.getElementById("listRadioBtn");
  optionsDisplay.forEach(function(item) {
  var div = document.createElement("div");
  div.setAttribute("class", "w3-cell w3-padding-right");
  
  options[item] = false;
  
  var radioBtn = document.createElement("input");
  radioBtn.setAttribute("type", "checkbox");
  radioBtn.setAttribute("id",item);
  radioBtn.setAttribute("value",item);
  
  var label = document.createElement("label");
  label.setAttribute("for", item);
  label.innerHTML = item;
  
  div.appendChild(radioBtn);
  div.appendChild(label);
  div.innerHTML += " ";
  listBtn.appendChild(div);
});

var listCheckbox = listBtn.getElementsByTagName("input");
for(var i = 0; i < listCheckbox.length; i++) {
  listCheckbox[i].addEventListener("change", function() {
    options[this.value] = this.checked;
    xsltProcessor1.setParameter(null, this.value, options[this.value]);
  });
}


       
  var sp=window.location.search.substring(1).split("&");
  if (sp[0]) validateUploadFile(sp[0],"URL");
};
    
function loadModeToPage() {
  document.getElementsByClassName("fa-refresh")[0].setAttribute("class", "w3-spin fa fa-spinner w3-xxlarge");
      //Generate modelDoc depending on method of upload file
  switch(options["method"]) {
    case "URL": //Not work now, we not support get with URL
      readXml(options["filepath"], function(Doc) { modelDoc =  Doc });
      if (modelDoc) {
        document.getElementById("fileName").innerHTML = options["filepath"].match(/[_-\w]+.xml/);
        document.getElementsByTagName("title")[0].innerHTML = options["filepath"].match(/[_-\w]+.xml/);
         modelDocDisplayToPage();
      }
      else {
         document.getElementById("errorMess").innerHTML = "Cannot read the document";
      }
    break;
    case "upload":
      document.getElementById("fileName").innerHTML = file.name;
      document.getElementsByTagName("title")[0].innerHTML = file.name;
      var reader = new FileReader();
      try {
        reader.readAsText(file);
        reader.onload = function() {
          modelDoc = new DOMParser().parseFromString(reader.result, "application/xml");
          if(modelDoc.firstElementChild.getAttribute("level") == 2) {
          modelDocDisplayToPage();
          }
          else {
            document.getElementById("errorMess").innerHTML = "File format is not supported" ;
          }      
        }    
      }
      catch(err) {
        document.getElementById("errorMess").innerHTML = "Cannot read the document";
      }
      break;
  } 

  document.getElementsByClassName("fa-spinner")[0].setAttribute("class", "fa fa-refresh  w3-xxxlarge"); //End spine progress-indicator
  function modelDocDisplayToPage() {

    // read and load table

    resultDocument = xsltProcessor1.transformToFragment(modelDoc, document);
    resultDocument = xsltProcessor1.transformToFragment(modelDoc, document);
    if (resultDocument.firstElementChild.innerHTML.match(/\= \?\?\? html\=/)) {
      document.getElementById("errorMess").innerHTML = "Incorrect XML";
    }
    else {
      w3_close();
      document.getElementById("mainContent").innerHTML = "";
      document.getElementById("mainContent").appendChild(resultDocument.firstElementChild);
  
      //update equations
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
      
      // read additional stylesheet

    }
  }  
}    
    
  function validateUploadFile(pathFile,method) {
    document.getElementById("errorMess").innerHTML = ""; //Delete message about error, when upload new file 

  if ((pathFile != "") && (pathFile.match(/(.xml)$/))) {
    switch(method) {
      case "URL": 
        options["filepath"] = pathFile;
        options["method"] = "URL";
        break;
    case "upload":
      options["method"] = "upload";
      break;
  }
  loadModeToPage(); 
  }
   else {
    document.getElementById("errorMess").innerHTML = "Cannot read the document";
    }
  }
    
    //transform element and open side window
function w3_open(event) {
  // transformation
  var id = event.target.id;
  readXml("xslt/"+options["transform2"]+".xsl", function(xsl2) {
    xsltProcessor2.setParameter(null, "elementId", event.target.id);
    var resultDocument = xsltProcessor2.transformToDocument(modelDoc); 
    document.getElementById("sideContent").removeChild(document.getElementById("sideContent").childNodes[0]);
    document.getElementById("sideContent").appendChild(resultDocument.firstElementChild);
 });
      
      
      // show block
  document.getElementById("sideInformBlock").style.display = "block";
      
 document.getElementById("sideInformBlock").setAttribute("class", "w3-container w3-col l2 m2 s2 w3-animate-right");
  document.getElementById("mainContent").setAttribute("class", "w3-container w3-col l10 m10 s10 w3-border-right w3-border-color-blue-grey");
      //update equations
  MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
  }

  function w3_close() {
    document.getElementById("sideInformBlock").setAttribute("class", "w3-container");
    document.getElementById("mainContent").setAttribute("class", "w3-container w3-col w3-border-right w3-border-color-blue-grey");
    document.getElementById("sideInformBlock").style.display = "none";
  }


