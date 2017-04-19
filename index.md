<script>
var dist = "dist/170418 online_0.2.0_beta/";
</script>
<div style="display:none;">
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/ru_RU/sdk.js#xfbml=1&version=v2.8";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>

<div class="fb-share-button" data-href="http://sbmlviewer.insilicobio.ru/" data-layout="button_count" data-size="large" data-mobile-iframe="false"><a class="fb-xfbml-parse-ignore" target="_blank" href="https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fsbmlviewer.insilicobio.ru%2F&amp;src=sdkpreparse">Share</a></div>

<a href="https://twitter.com/share" class="twitter-share-button" data-size="large" data-show-count="false">Tweet</a><script async src="http://platform.twitter.com/widgets.js" charset="utf-8"></script>

<div class="g-plus" data-action="share" data-annotation="bubble"></div><script src="https://apis.google.com/js/platform.js" async defer></script>

<div class="share42init"></div>
<script type="text/javascript" src="/js/share42.js"></script>
<script type="text/javascript" src="http://sbmlviewer.insilicobio.ru/assets/js/script.js"></script>

</div>

# SBML Viewer
**SBML Viewer** is a tool for fast and easy reading models written in SBML format. It allows looking through model components and equations even if you have no modeling software installed. It is as simple as reading a web page in your web browser.

SBML Viewer never uploads your files to server and all transformation are performed locally in your browser, so it is safe. It is free. 

When **SBML Viewer** is helpful:

* You have no facilities to install you favorite tool to read and check some SBML file right now.
* Your software cannot read some specific SBML versions or elements like "event", "constraint" or "functionDefinition" etc. but the file includes them.
* You need to share your model in human readable format with someone easily.
* Your have some errors when reading foreign SBML and are trying to check the structure.

## About SBML
SBML is a free and open interchange format for computer models of biological processes, see [SBML community portal](http://sbml.org/). It is used in many modeling application and can store model structure, math and annotation of elements. SBML is XML based format and designed basically for machine reading and writing.

# Quick start <code><a id="demoLink" href="#"><div id="tryDemo" class="w3-btn w3-card-2 w3-green w3-circle w3-display-topmiddle" style="position:absolute;"><img src="http://sbmlviewer.insilicobio.ru/assets/img/click.png">   Try demo online</div></a></code>

Your model is available from web:

1. Your model is shared on <code>http://www.example.com/your_sbml_file.xml<code>
2. Write the line in your favorite browser <code>http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://www.example.com/your_sbml_file.xml<code>

Your model is available locally:
1. The following http://sbmlviewer.insilicobio.ru/viewer.xhtml
1. Click on button "Выберите файл"("Choose file") and choose file

## Options
### useNames
desciption
### correctMathml
desciption
### equationsOff
Hidden equations








# Examples
To look through example just try the links
* [test 00001 from SBML Test Suite Database](http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/00001-sbml-l2v5.xml)
* [BIOMD0000000512 from BioModels Database, model of the month in January 2016](http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/BIOMD0000000512.xml)
* [BIOMD0000000622 from BioModels Database, model of the month in January 2017](http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/BIOMD0000000622.xml)
* [BIOMD0000000439 from BioModels Database, model of the month in October 2016](http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/BIOMD0000000439.xml)

# Releases

## Current release

- reading SBML Level 2 Version 1-5
- creating tabular view of model with: **sbml2table** transformation
- summary generation for chosen element: **sbml2element** transformation

## Known restrictions
- wrong view of <code>parameter</code> element inside <code>kineticLaw</code>
- ignore <code>annotation</code> elements

## Roadmap

- Chrome extension for sbmlviewer
- Transformation to Antimony format: **sbml2antimony** transformation
- **sbml2report** transformation
- **sbml2tree** transformation

# Other information

## Subscribe for updates
<div class="w3-button w3-large w3-round w3-green" style="color:white">
  <img src="http://sbmlviewer.insilicobio.ru/assets/img/subscrip.png">
<a style="color:white" href="http://eepurl.com/cxCiu5">Subscription</a>
</div>
## Authors

- Evgeny Metelkin @metelkin
- Viktoria Tkachenko @vetedde

## License
Apache 2.0

## 3d party software

- [MathJax](https://www.mathjax.org)
- [W3.CSS](http://www.w3schools.com/w3css/) 
