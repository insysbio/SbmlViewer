'use strict'

var options = {
  transform: "sbml2table",
  transform2: "sbml2element"
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

var xsltProcessor1 = new XSLTProcessor(); //processor for 1st xslt
var xsltProcessor2 = new XSLTProcessor(); //processor for 2d xslt
var curFile = {
  "content": null, // model in dom-fromat 
  "name": null,
  "file": null, //link to File or path of file
  "method": null //method, that was uploaded the file
}
var curModel = null; // model in dom-fromat 
var curMethod = null; //method, that was uploaded the file

window.onload = function () {
  console.log("Window onload");
  
  createInterface();
  createListener();

  /*Set size of content*/
  resizeContent();
  
  /*Read XSLT templetes*/
  readXmlHTTP("xslt/"+options["transform"]+".xsl", function(xsl1) {
    console.log("Try import stylesheet for main tables and set parameters");
    
    try {
      xsltProcessor1.importStylesheet(xsl1);
      
      xsltProcessor1.setParameter(null, "useNames", options["useNames"]);
      xsltProcessor1.setParameter(null, "correctMathml", options["correctMathml"]);
      xsltProcessor1.setParameter(null, "equationsOff", options["equationsOff"]);
      
      console.log(" Success");
    }
    catch(err) {
      document.getElementById("errorMess").innerHTML = "Cannot display stylesheet";
      console.log(" Err: :", err);
    }
  });

  readXmlHTTP("xslt/"+options["transform2"]+".xsl", function(xsl2) {
    console.log("Try import stylesheet for element's table(side infoblock) and set parameters");
    
    try {
      xsltProcessor2.importStylesheet(xsl2);
      
      xsltProcessor2.setParameter(null, "useNames", options["useNames"]);
      xsltProcessor2.setParameter(null, "correctMathml", options["correctMathml"]);
      
      console.log(" Success");
    }
    catch(err) {
      document.getElementById("errorMess").innerHTML = "Cannot display stylesheet";
      console.log(" Err: :", err);
    }
    

  });

  /* Check URL for link a model  */
  var sp = window.location.search.substring(1).split("&");
  if (sp[0]) {
    console.log("URL has link to file");
    
    curFile["file"] = sp[0];
    curFile["method"] = "URL";
    
    readFile(sp[0], "URL", function(modelDoc) {
      console.log("File(url) read, content:", modelDoc);
      
      curFile["content"] = modelDoc["content"];
      curFile["name"] = modelDoc["name"];
      
      displayModel(modelDoc["content"], modelDoc["name"]);
      
      endSpin();
    });
  }
  else {
    endSpin();
  }

  function createInterface() {
  /* Generate Transformation type dropdown list*/
    waysDisplayPage.forEach(function(item) {
      var option = document.createElement("option");
      option.appendChild(document.createTextNode(item));
      document.getElementById("transformationType").appendChild(option);  //Add generated option to <select></select> with id "transformationType"
    });
    
    /* Generate bar of checkboxes for options display from optionsDisplay*/
    optionsDisplay.forEach(function(item) {
      var div = document.createElement("div");
      div.setAttribute("class", "w3-cell w3-padding-right");
      
      options[item] = false; //Default value
      
      var checkboxBtn = document.createElement("input");
      checkboxBtn.setAttribute("type", "checkbox");
      checkboxBtn.setAttribute("id", item);
      
      var label = document.createElement("label");
      label.setAttribute("for", item);
      label.appendChild(document.createTextNode(item));
      
      div.appendChild(checkboxBtn);
      div.appendChild(label);
      document.getElementById("listOptionsCheckbox").appendChild(div);
    }); 
    
    console.log("Interface created");
  }

  function createListener() {
  /** Listen click on button "file", validate, run reading and display  */
    document.getElementById("file").addEventListener("change", function() {
      console.log("Upload file with help btn");
      
      startSpin();
      clearErrMess();
      
      curFile["file"] = document.getElementById("file").files[0];
      curFile["method"] = "upload";
      
      readFile(document.getElementById("file").files[0], "upload", function(modelDoc) {
        console.log("File read(upload), content:", modelDoc);
        
        curFile["content"] = modelDoc["content"];
        curFile["name"] = modelDoc["name"];
        
        displayModel(modelDoc["content"], modelDoc["name"]);
        
        endSpin();
      });
    }, false);
    

  /** Listen click on button "refresh", read file again accroding with current method and update display */  
  document.getElementById("refresh").addEventListener("click", function() {
    console.log("Run refresh");
    
    startSpin();
    clearErrMess();
    
    readFile(curFile["file"], curFile["method"], function(modelDoc) {
      console.log("File read(refresh), content:", modelDoc);
      
        curFile["content"] = modelDoc["content"];
        
        displayModel(modelDoc["content"]);
        
        endSpin();
      });
  });
  
  /** Drag'n'drop */
    
    /** Stop default drop event and run function to read file and run function to display content after read  */
    document.addEventListener("drop", function(event) {
      event.preventDefault();
      event.stopPropagation();
      
      console.log("File drop");
      
      startSpin();
      clearErrMess();
      
      curFile["file"] = event.dataTransfer.files[0];
      curFile["method"] = "upload";
      
      readFile(event.dataTransfer.files[0], "upload", function(modelDoc) {
        console.log("File read(drop), content:", modelDoc);
        
        curFile["content"] = modelDoc["content"];
        curFile["name"] = modelDoc["name"];
        
        displayModel(modelDoc["content"], modelDoc["name"]);
        
        endSpin();
      });
    });

    /** Stop default dragstart event*/
    document.addEventListener("dragstart", function(event) {
      event.preventDefault();
    }); 

    /** Stop default dragover event*/
    document.addEventListener("dragover", function(event) {
      event.preventDefault();
    });
    
    /** Listen change dropdown lost of Transformation type, update settings of display table and refresh display*/
    document.getElementById("transformationType").addEventListener("change", function() {
      console.log("Select Transformation Type", this.value);
      
      startSpin();
      clearErrMess();
      
      options["transform"] = this.value;
      
      console.log("Try import stylesheet for", this.value," and set parameters");
      readXmlHTTP("xslt/"+options["transform"]+".xsl", function(xsl1) {
        try {
          xsltProcessor1.importStylesheet(xsl1);
          
          xsltProcessor1.setParameter(null, "useNames", options["useNames"]);
          xsltProcessor1.setParameter(null, "correctMathml", options["correctMathml"]);
          xsltProcessor1.setParameter(null, "equationsOff", options["equationsOff"]);
          
          displayModel(curFile["content"]);
          
          console.log(" Success");
        }
        catch(err) {
          console.log(" Err: ", err);
        }
        
        endSpin();
      });
      }, true);
    
    
    /** Listen click on checkbox of Options display and  update settings of display table*/
    var listCheckbox = document.getElementById("listOptionsCheckbox").getElementsByTagName("input");
    for(var i = 0; i < listCheckbox.length; i++) {
      listCheckbox[i].addEventListener("change", function() {
        console.log("Click on ", this.id);
        
        options[this.id] = this.checked;
        xsltProcessor1.setParameter(null, this.id, options[this.id]);
      });
    }
    
    /**Listen change size of window and edit height of */
    window.addEventListener("resize", resizeContent);
    
    console.log("Events listen");
    }
        
}



/** Read file according with method and with help callback return object data, include name and content
* @param {string|object} - file. If method is "URL", then file - path file, if - "upload", then object File
*/
function readFile(f, method, callback) {
  console.log("Run read file");
  
  var f, data = {
    "name": null,
    "content": null
  };
  
  switch(method) {
    case "URL":
      data["name"] = f.match(/[_-\w]+.xml/);
      
      readXmlHTTP(f, function(Doc) { 
        data["content"] =  Doc; 
        callback(data); 
      });
      break;
    case "upload":
      data["name"] = f.name;
      
      readXmlUpload(f, function(Doc) { 
        data["content"] =  Doc; 
        callback(data); 
      });
      break;
  }
  
}

/** Get file and return content of file in format XML-DOM
* @param {string} filepath
*/
function readXmlHTTP(filepath, callback) {
  console.log("Try read ",filepath , " with help HTTP");
  
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET", filepath, false);       
  xmlhttp.onload = function(){
    console.log(" Success");
    callback(this.responseXML);
  };
       
  xmlhttp.error = function(){
    console.log(" Err: ", err);
    document.getElementById("errorMess").innerHTML = "Cannot read the file";
  };
       
  xmlhttp.send();
}

/** Read file and return content of file in format XML-DOM
* @param {object} f - file of model(object File)
*/
function readXmlUpload(f, callback) {
  console.log("Try read with help FileReader");
  
  var reader = new FileReader();
  reader.readAsText(f);
  reader.onload = function() {
    try {
      console.log(" Success");
      callback(new DOMParser().parseFromString(reader.result, "application/xml"));
    }
    catch(err) {
      console.log(" Err: ", err);
      document.getElementById("errorMess").innerHTML = "Cannot read the file";
    }
  }
};  


/** Display model into screen(div[id="mainContent"]) and name of file. If 
* @param {object} model - DOM-object of content model
* @param {string} name - name of file, that content model. Optional variable, transmitted only when the model is first displayed 
*/
function displayModel(model, name) {
  //Display name of file into title and beside btn of upload file
  console.log("Run display");
  
  if (name) {
    document.getElementById("fileName").innerHTML = name;
    document.getElementsByTagName("title")[0].innerHTML = name;
  }
  
  console.log("Try transformToFragment");
  try {
    var resultDocument = xsltProcessor1.transformToFragment(model, document);
    console.log(" Success");
    
    console.log("Try display model");
    if (resultDocument.firstElementChild.innerHTML.match(/\= \?\?\? html\=/)) {
      console.log(" Err: Incorrect XML");
      document.getElementById("errorMess").innerHTML = "Incorrect XML";
    }
    else {
      var mainContent = document.getElementById("mainContent");
      
      //Close side window with information about element(if it open)
      w3_close(); 
      
      //Clear mainContent(display of model)
      while (mainContent.childNodes[0]) {
        mainContent.removeChild(mainContent.childNodes[0]);
      }
      
      //Append new display of content
      mainContent.appendChild(resultDocument.firstElementChild);
    
      //update equations
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
      
      console.log(" Success display")

    }
  }
  catch(err) {
    document.getElementById("errorMess").innerHTML = "Incorrect XML";
    console.log(" Err: ", err);
  }
}

/** Open side window with information about select element model
* @param {object} event - event, that caused the function. From it, the element's id gets
*/
function w3_open(event) {
  //element, that was clicked
  var id = event.target.id, sideContent = document.getElementById("sideContent");
  
  while (sideContent.childNodes[0]) {
    sideContent.removeChild(sideContent.childNodes[0]);
  }
  
  xsltProcessor2.setParameter(null, "elementId", id);
  try {
    var resultDocument = xsltProcessor2.transformToDocument(curFile["content"]);
    sideContent.appendChild(resultDocument.firstElementChild);
  }  
  catch(err) {
    console.log(err);
    var p = document.createElement("p");
    p.setAttribute("class", "w3-text-red w3-center w3-large w3-padding");
    p.appendChild(document.createTextNode("Cannot display element"));
    sideContent.appendChild(p);
  }
  

  
      
  // show block
  document.getElementById("sideInformBlock").style.display = "block";
  document.getElementById("sideInformBlock").setAttribute("class", "w3-container w3-col l3 m3 s3 w3-animate-right");
  document.getElementById("mainContent").setAttribute("class", "w3-container w3-col l9 m9 s9 w3-border-right w3-border-color-blue-grey");
  
  //update equations
  MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
}

/** Close side window with information about select element model
*/
function w3_close() {
  document.getElementById("sideInformBlock").setAttribute("class", "w3-container");
  document.getElementById("mainContent").setAttribute("class", "w3-container w3-col w3-border-right w3-border-color-blue-grey");
  document.getElementById("sideInformBlock").style.display = "none";
}

/** Resize window with info about model(mainContent) and window with info about select element of model(sideContent). 7px - height of scroll
*/
function resizeContent() {
  var newHeight = document.documentElement.clientHeight - document.getElementById("optionsArea").clientHeight - 7 +"px";
  document.getElementById("mainContent").style.height = newHeight;
  document.getElementById("sideContent").style.height = newHeight;
}

function clearErrMess() {
  var errMess = document.getElementById("errorMess");
    while (errMess.childNodes[0]) {
      errMess.removeChild(errMess.childNodes[0]);
  }
}

function startSpin() {
  document.getElementById("spinner").setAttribute("class", "w3-spin fa fa-spinner w3-xxlarge");
}

function endSpin() {
  document.getElementById("spinner").setAttribute("class", "fa fa-refresh  w3-xxxlarge");
}