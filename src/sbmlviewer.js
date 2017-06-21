'use strict'

var options = {
  transform: "sbml2table",
  transform2: "sbml2element"
};
  
var waysDisplayPage = [
  "sbml2table",
  "sbml2math"
];
  
var optionsDisplay = {
  "useNames": { "title": "Some title 1", "notes": "note: useNames"},
  "correctMathml": { "title": "Some title 2", "notes": "note: correctMathml"},
  "equationsOff": { "title": "Some title 3", "notes": "note: equationsOff"}
};

var xsltProcessor1 = new XSLTProcessor(); //processor for 1st xslt
var xsltProcessor2 = new XSLTProcessor(); //processor for 2d xslt
var curFile = {
  "content": null, // model in dom-fromat 
  "name": null,
  "file": null, //link to File or path of file
  "method": null //method, that was uploaded the file
}

window.onload = function () {
  console.log("Window onload");
  
  createInterface();
  createListener();

  /*Set size of content*/
  resizeContent();
  
  /*Read XSLT templetes*/
  readXmlHTTP("xslt/"+options["transform"]+".xsl", function(xsl1) {
    console.log("Import stylesheet for main tables and set parameters...");
    
    try {
      xsltProcessor1.importStylesheet(xsl1);
      
      xsltProcessor1.setParameter(null, "useNames", options["useNames"]);
      xsltProcessor1.setParameter(null, "correctMathml", options["correctMathml"]);
      xsltProcessor1.setParameter(null, "equationsOff", options["equationsOff"]);
      
      console.log(" Success");
    }
    catch(err) {
      showErrMess("Cannot display stylesheet");
      console.error(" Err: :", err);
    }
  });

  readXmlHTTP("xslt/"+options["transform2"]+".xsl", function(xsl2) {
    console.log("Import stylesheet for element's table(side infoblock) and set parameters...");
    
    try {
      xsltProcessor2.importStylesheet(xsl2);
      
      xsltProcessor2.setParameter(null, "useNames", options["useNames"]);
      xsltProcessor2.setParameter(null, "correctMathml", options["correctMathml"]);
      
      console.log(" Success");
    }
    catch(err) {
      showErrMess("Cannot display stylesheet");
      console.error(" Err: :", err);
    }
    

  });

  /* Check URL for link a model  */
  var sp = window.location.search.substring(1).split("&");
  if (sp[0]) {
    console.log("Add file(URL)");
    clearContent();
    
    curFile["file"] = sp[0]; //for URL is path(str)
    curFile["method"] = "URL";
    curFile["name"] = curFile["file"].match(/[_-\w]+.xml/)[0];
    
    displayName(curFile["name"]);
    
    readFile(sp[0], "URL", function(modelDoc) {
      console.log("File(URL) read, content:", modelDoc);
      
      curFile["content"] = modelDoc;
      
      displayModel(curFile["content"]);
      
    });
  }
  endSpin();


  function createInterface() {
  /* Generate Transformation type dropdown list*/
    waysDisplayPage.forEach(function(item) {
      var option = document.createElement("option");
      option.appendChild(document.createTextNode(item));
      document.getElementById("transformationType").appendChild(option);  //Add generated option to <select></select> with id "transformationType"
    });
    
    /* Generate bar of checkboxes for options display from optionsDisplay*/
    var item;
    for (item in optionsDisplay)  {
      var div = document.createElement("div");
      div.classList.add("w3-cell", "w3-padding-right", "w3-tooltip");
      
      options[item] = false; //Default value
      
      var p = document.createElement("p");
      
      var checkboxBtn = document.createElement("input");
      checkboxBtn.setAttribute("type", "checkbox");
      checkboxBtn.setAttribute("id", item);
      
      var label = document.createElement("label");
      label.setAttribute("for", item);
      label.appendChild(document.createTextNode(optionsDisplay[item]["title"]));
      
      p.appendChild(checkboxBtn);
      p.appendChild(label);
      
      
      var note = document.createElement("p");
      note.appendChild(document.createTextNode(optionsDisplay[item]["notes"]));
      note.classList.add("w3-text", "w3-tag","w3-tiny", "w3-animate-opacity", "noteOptions");
      
      div.appendChild(p);
      div.appendChild(note);
      document.getElementById("listOptionsCheckbox").appendChild(div);
    }
    console.log("Interface created");
  }

  function createListener() {
  /** Listen click on button "file", validate, run reading and display  */
    document.getElementById("file").addEventListener("change", function() {
      startSpin();
      
      if (document.getElementById("file").files[0]) {
        console.log("Add file(on click btn)");       
        
        clearContent();
        clearErrMess();
        
        curFile["file"] = document.getElementById("file").files[0];
        curFile["method"] = "upload";
        curFile["name"] = curFile["file"].name;
        
        displayName(curFile["name"]);
        
        readFile(curFile["file"], curFile["method"], function(modelDoc) {
          console.log("File read(upload), content:", modelDoc);
          
          curFile["content"] = modelDoc;
                    
          displayModel(curFile["content"]);
          
          endSpin();
        });
      }
    }, false);
    

  /** Listen click on button "refresh", read file again accroding with current method and update display */  
  document.getElementById("refresh").addEventListener("click", function() {
    console.log("Run refresh. File:", curFile["file"], "method: ", curFile["method"]);
    
    startSpin();
    clearContent();
    clearErrMess();
    
    readFile(curFile["file"], curFile["method"], function(modelDoc) {
      console.log("File read(refresh", curFile["method"],"), content:", modelDoc);
      
        curFile["content"] = modelDoc;
        
        displayModel(curFile["content"]);
        
        endSpin();
      });
  });
  
  /** Drag'n'drop */
    
    /** Stop default drop event and run function to read file and run function to display content after read  */
    document.addEventListener("drop", function(event) {
      event.preventDefault();
      event.stopPropagation();
      
      console.log("Add file(drop)");
      
      startSpin();
      clearContent();
      clearErrMess();
      
      curFile["file"] = event.dataTransfer.files[0];
      curFile["method"] = "upload";      
      curFile["name"] = curFile["file"].name;
      
      displayName(curFile["name"]);
      
      readFile(curFile["file"], curFile["method"], function(modelDoc) {
        console.log("File read(drop), content:", modelDoc);
        
        curFile["content"] = modelDoc;
        
        displayModel(curFile["content"]);
        
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
      clearContent();
      
      options["transform"] = this.value;
      
      console.log("Import stylesheet for", this.value," and set parameters...");
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
          console.error(" Err: ", err);
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
  
  switch(method) {
    case "URL":
      readXmlHTTP(f, function(Doc) { 
        callback(Doc); 
      });
      break;
    case "upload":      
      readXmlUpload(f, function(Doc) { 
        callback(Doc); 
      });
      break;
  }
  
}

/** Get file and return content of file in format XML-DOM
* @param {string} filepath
*/
function readXmlHTTP(filepath, callback) {
  console.log("Read ", filepath, " with help HTTP...");
  
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET", filepath, false);       
  xmlhttp.onload = function(){
    console.log(" Success");
    callback(this.responseXML);
  };
       
  /*xmlhttp.error = function(){
    console.error(" Err: ", err);
    showErrMess("Cannot read the file");
  };*/
       
  try {
    xmlhttp.send();
  }
  catch(err) {
    console.error(" Err: ", err);
    showErrMess("Cannot read the file");    
  }
}

/** Read file and return content of file in format XML-DOM
* @param {object} f - file of model(object File)
*/
function readXmlUpload(f, callback) {
  console.log("Read with help FileReader...");
  
  var reader = new FileReader();
  reader.readAsText(f);
  reader.onload = function() {
    try {
      console.log(" Success");
      callback(new DOMParser().parseFromString(reader.result, "application/xml"));
    }
    catch(err) {
      console.error(" Err: ", err);
      showErrMess("Cannot read the file");
    }
  }
};  


/** Display model into screen(div[id="mainContent"]) and name of file. If 
* @param {object} model - DOM-object of content model
* @param {string} name - name of file, that content model. Optional variable, transmitted only when the model is first displayed 
*/
function displayModel(model) {
  //Display name of file into title and beside btn of upload file
  console.log("Run display");
  console.log("Check level of SBML...");
  
  
  if (model.firstElementChild.getAttribute("level") == 2) {
    console.log("Ok/n Transform to fragment...");
    try {
      var resultDocument = xsltProcessor1.transformToFragment(model, document);
      console.log(" Success");
      console.log("Display model...");

      if (resultDocument.firstElementChild.innerHTML.match(/\= \?\?\?/) || resultDocument.firstElementChild.innerHTML.match(/This page contains the following errors/)) { //
        console.error(" Err: Incorrect XML");
        showErrMess("Incorrect XML");
      }
      else {
        var mainContent = document.getElementById("mainContent");
        
        //Close side window with information about element(if it open)
        //w3_close(); 
               
        //Append new display of content
        document.getElementById("mainContent").appendChild(resultDocument.firstElementChild);
        
        //update equations
        MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
        
        console.log(" Success");
      }
    }
    catch(err) { //if transfrom not success
      showErrMess("Incorrect XML");
      console.error(" Err: ", err);
    }
  }  
  else { //if level of file is not 2
    showErrMess("File format is not supported");
    console.error(" File format is not supported");  
  }    
  
}

function displayName(name) {
  document.getElementById("fileName").innerHTML = name;
  document.getElementsByTagName("title")[0].innerHTML = name;
}

/** Open side window with information about select element model
* @param {object} event - event, that caused the function. From it, the element's id gets
*/
function w3_open(event) {
  clearErrMess();
  
  console.log("Display information about element...");
  //element, that was clicked
  var id = event.target.id, sideContent = document.getElementById("sideContent");
  
  console.log(" Clear display...");
  while (sideContent.childNodes[0]) {
    sideContent.removeChild(sideContent.childNodes[0]);
  }
  console.log("   Success");
  
  console.log(" Transform data to document...");
  xsltProcessor2.setParameter(null, "elementId", id);
  try {
    var resultDocument = xsltProcessor2.transformToDocument(curFile["content"]);
    sideContent.appendChild(resultDocument.firstElementChild);
    console.log("   Success\n Success display");//Transform
  }  
  catch(err) {
    console.error(" Err:", err);
    var p = document.createElement("p");
    p.classList.add("class", "w3-text-red", "w3-center", "w3-large", "w3-padding");
    p.appendChild(document.createTextNode("Cannot display element"));
    sideContent.appendChild(p);
  }
  

  
      
  // show block
  document.getElementById("sideInformBlock").style.display = "block";
  document.getElementById("sideInformBlock").classList.add( "w3-col", "l3", "m3", "s3", "w3-animate-right");
  document.getElementById("mainContent").classList.add("l9", "m9", "s9");
  
  //update equations
  MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
}

/** Close side window with information about select element model
*/
function w3_close() {
  document.getElementById("sideInformBlock").classList.remove( "l3", "m3", "s3",  "w3-animate-right");
  document.getElementById("mainContent").classList.remove("l9", "m9", "s9");
  document.getElementById("sideInformBlock").style.display = "none";
}

function clearContent() {
  console.log("Clear content");
  var mainContent = document.getElementById("mainContent");
  
  //Clear mainContent(display of model)
  while (mainContent.childNodes[0]) {
    mainContent.removeChild(mainContent.childNodes[0]);
  }
  
  w3_close();
}

/** Resize window with info about model(mainContent) and window with info about select element of model(sideContent). 7px - height of scroll
*/
function resizeContent() {
  var newHeight = document.documentElement.clientHeight - document.getElementById("optionsArea").clientHeight - 7 +"px";
  document.getElementById("mainContent").style.height = newHeight;
  document.getElementById("sideContent").style.height = newHeight;
}

function clearErrMess() {
  document.getElementById("errorContainer").style.display = "none";
  var errMess = document.getElementById("errorMess");
    while (errMess.childNodes[0]) {
      errMess.removeChild(errMess.childNodes[0]);
  }
}

function showErrMess(mess) {
  document.getElementById("errorContainer").style.display = "block";
  document.getElementById("errorMess").appendChild(document.createTextNode(mess));
}

function startSpin() {
  console.log("Start spin");
  //document.getElementById("spinner").setAttribute("class", "w3-spin fa fa-spinner w3-xxlarge");  
  document.getElementById("spinner").classList.remove("fa-refresh");
  document.getElementById("spinner").classList.add("w3-spin", "fa-spinner");
}

function endSpin() {
  //document.getElementById("spinner").setAttribute("class", "fa fa-refresh  w3-xxxlarge");   
  document.getElementById("spinner").classList.remove("w3-spin", "fa-spinner");
  document.getElementById("spinner").classList.add("fa-refresh");  
  console.log("End spin");
}