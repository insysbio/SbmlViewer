function readTestFile(x, callback) { 
  var filehttp = new XMLHttpRequest();
  filehttp.open("GET", x, false);       
  filehttp.onload = function(){
    callback(this.responseText);
  };
}
var URL = "http://jobtest.ru/sbmlviewer/cases/superexample-l2v1.xml";
var inpFile = null;


describe("Generate panel Options", function() {
    it("Generate \"Options type\"", function() {
      assert.isTrue(documentMod.getElementsByTagName("select")[0].getElementsByTagName("option").length != 0);
    });
    it("Generate \"Options display\"", function() {
      assert.equal(documentMod.getElementById("listRadioBtn").getElementsByTagName("input").length, 3);
    });    
});  

describe("Upload file use button or drag'n'drop", function() {
    it("File given", function() {
      if (document.getElementById("inputFile").files[0]) documentMod.getElementById("file").files = document.getElementById("inputFile").files;
      assert.equal(documentMod.getElementById("file").files[0],document.getElementById("inputFile").files[0]);
    });
    commonTest();
});

describe("Upload file use URL", function() {
    it("File given", function() {
      var new_src = document.getElementById("iframe").getAttribute("src")+"?"+URL;
      document.getElementById("iframe").setAttribute("src",new_src);
      assert.equal(document.getElementById("iframe").getAttribute("src"),new_src);
    });
    commonTest();
});

function commonTest() {
    it("Name add", function() {
      assert.isTrue((documentMod.getElementById("fileName").innerHTML != "") && (documentMod.getElementById("fileName").innerHTML != "No file choosen"));
    });

    it("Not errors", function() {
       document.getElementById('iframe').onload = function() {
        assert.isTrue(documentMod.getElementById("errorMess").innerHTML == "");
       }  
    });    

    it("Add content", function() {
       document.getElementById('iframe').onload = function() {
        var crit = documentMod.getElementById("mainContent").getElementsByTagName("div")[0].innerHTML != "Nothing to show"; 
        assert.isTrue(crit);
       }
    });

    it("An active element is open", function() {
      document.getElementById('iframe').onload = function() {
        var content = documentMod.getElementById("mainContent").innerHTML;
        var targetId = content.match(/<span [\w\d\:\/\-\.\=\"\;\ ]+ onclick="w3_open\(event\)" id="([\w\d]+)"/)[1];
        var eventOpen = {target: {"id":targetId}};
        document.getElementById('iframe').contentWindow.w3_open(eventOpen);
        assert.isTrue((documentMod.getElementById("sideContent").innerHTML != "fff") && (documentMod.getElementById("sideContent").innerHTML != ""));
      };
    });

  it("Option equationsOff and button \"Refresh\" is work(other options probably too)", function() {
    document.getElementById('iframe').onload = function() {
      documentMod.getElementById("useNames").checked = true;
      var myClick = new Event("click");
      documentMod.getElementById("refresh").dispatchEvent(myClick);
      assert.isNotNull(documentMod.getElementById("mainContent").getElementsByTagName("div")[0].innerHTML.match(/Equations are hidden/));
    } 
  });
  
  it("Test true", function(){
    assert.isTrue(2*2 == 4);
  });  
  it("Test true", function(){
    assert.isTrue(2*2 != 4);
  });  
}  
