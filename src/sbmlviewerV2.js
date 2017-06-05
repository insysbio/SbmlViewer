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
var curModel = null;

window.onload = function () {
  createInterface();
  createListener();
  
  /*Set size of content*/
  resizeContent();
  
  /*Read XSLT templetes*/
  readXmlHTTP("xslt/"+options["transform"]+".xsl", function(xsl1) {
    xsltProcessor1.importStylesheet(xsl1);
  
    xsltProcessor1.setParameter(null, "useNames", options["useNames"]);
    xsltProcessor1.setParameter(null, "correctMathml", options["correctMathml"]);
    xsltProcessor1.setParameter(null, "equationsOff", options["equationsOff"]);
  });

  readXmlHTTP("xslt/"+options["transform2"]+".xsl", function(xsl2) {
    xsltProcessor2.importStylesheet(xsl2);
    xsltProcessor2.setParameter(null, "useNames", options["useNames"]);
    xsltProcessor2.setParameter(null, "correctMathml", options["correctMathml"]);
  });

  /* Check URL for link a model  */
  var sp = window.location.search.substring(1).split("&");
  if (sp[0]) {
    readFile(sp[0] ,"URL", function(modelDoc) {
      curModel = modelDoc;
      displayModel(modelDoc["content"], modelDoc["name"]);
    });
  }

  function createInterface() {
  /* Generate Transformation type dropdown list*/
    waysDisplayPage.forEach(function(item) {
      var option = document.createElement("option");
      option.appendChild(document.createTextNode(item));
      document.getElementById("transformationType").appendChild(option);  //Add generated option to <select></select> with id "transformationType"
    });
    
    /* Generate bar of checkboxes for options display from optionsDisplay*/
    var listBtn = document.getElementById("listRadioBtn");
    optionsDisplay.forEach(function(item) {
      var div = document.createElement("div");
      div.setAttribute("class", "w3-cell w3-padding-right");
      
      options[item] = false; //Default value
      
      var radioBtn = document.createElement("input");
      radioBtn.setAttribute("type", "checkbox");
      radioBtn.setAttribute("id",item);
      radioBtn.setAttribute("value",item);
      
      var label = document.createElement("label");
      label.setAttribute("for", item);
      label.appendChild(document.createTextNode(item));
      
      div.appendChild(radioBtn);
      div.appendChild(label);
      listBtn.appendChild(div);
    });  
  }

  function createListener() {
  /** Listen click on button "file", validate, run reading and display  */
    document.getElementById("file").addEventListener("change", function() {
      readFile(document.getElementById("file").files[0], "upload", function(modelDoc) {
        curModel = modelDoc;
        displayModel(modelDoc["content"], modelDoc["name"]);
      });
    }, false);
    

  /** Listen click on button "refresh" and update display model */  
  document.getElementById("refresh").addEventListener("click", function() {
    displayModel(curModel["content"]);
  });
  
  /** Drag'n'drop */
    
    /** Stop default drop event and upload file */
    document.addEventListener("drop", function(event) {
      event.preventDefault();
      event.stopPropagation();
      readFile(event.dataTransfer.files[0], "upload", function(modelDoc) {
        curModel = modelDoc;
        displayModel(modelDoc["content"], modelDoc["name"]);
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
    
    /** Listen change dropdown lost of Transformation type, update settings of display table and refresh table*/
    document.getElementById("transformationType").addEventListener("change", function() {
      options["transform"] = this.value;
      readXmlHTTP("xslt/"+options["transform"]+".xsl", function(xsl1) {
      
      xsltProcessor1.importStylesheet(xsl1);
      
      xsltProcessor1.setParameter(null, "useNames", options["useNames"]);
      xsltProcessor1.setParameter(null, "correctMathml", options["correctMathml"]);
      xsltProcessor1.setParameter(null, "equationsOff", options["equationsOff"]);
      
      displayModel(curModel["content"]);
      });
      
      //NEED run update
      }, true);
    
    
    /** Listen click on checkbox of Options display and  update settings of display table*/
    var listCheckbox = document.getElementById("listRadioBtn").getElementsByTagName("input");
    for(var i = 0; i < listCheckbox.length; i++) {
      listCheckbox[i].addEventListener("change", function() {
        options[this.value] = this.checked;
        xsltProcessor1.setParameter(null, this.value, options[this.value]);
      });
    }
    
    /**Listen change size of window and edit height of */
    window.addEventListener("resize", resizeContent);
    }
        
}



/** Read file according with method and with help callback return object data, include name and content
* @param {string|object} -file. If method is "URL", then file - path file, if - "upload", then object File
*/
function readFile(f, method, callback) {
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

function readXmlHTTP(x, callback) { // return xml object as readed from file 
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

function readXmlUpload(f, callback) {
  var reader = new FileReader();
  reader.readAsText(f);
  reader.onload = function() {
    callback(new DOMParser().parseFromString(reader.result, "application/xml"));
  }
};  


/**
*/
function displayModel(model, name) {
  if (name) {
    document.getElementById("fileName").innerHTML = name;
    document.getElementsByTagName("title")[0].innerHTML = name;
  }
  
  var resultDocument = xsltProcessor1.transformToFragment(model, document);
  
  if (resultDocument.firstElementChild.innerHTML.match(/\= \?\?\? html\=/)) {
    document.getElementById("errorMess").innerHTML = "Incorrect XML";
  }
  else {
    /*w3_close();*/
    document.getElementById("mainContent").innerHTML = "";
    document.getElementById("mainContent").appendChild(resultDocument.firstElementChild);
  
    //update equations
    MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

  }
}

function w3_open(event) {
  // transformation
  var id = event.target.id;

  xsltProcessor2.setParameter(null, "elementId", event.target.id);
  var resultDocument = xsltProcessor2.transformToDocument(curModel["content"]); 
  if (document.getElementById("sideContent").childNodes.length > 0) document.getElementById("sideContent").removeChild(document.getElementById("sideContent").childNodes[0]);
  document.getElementById("sideContent").appendChild(resultDocument.firstElementChild);
      
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

function resizeContent() {
var newHeight = document.documentElement.clientHeight - document.getElementById("optionsArea").clientHeight - 7 +"px";
  document.getElementById("mainContent").style.height = newHeight;
  document.getElementById("sideContent").style.height = newHeight;
}