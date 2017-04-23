
**SbmlViewer** is a tool for fast and easy reading biologycal models written in SBML format. It allows looking through model components and equations even if you have no modeling software installed. It is as simple as reading a web page in your web browser.

SbmlViewer never uploads your files to the server and all transformations are performed locally in your browser, so it is safe and secure for your code.

SbmlViewer is open project located on [GitHub](https://github.com/insysbio/SbmlViewer). Any feedback is welcomed on [Issues page](https://github.com/insysbio/SbmlViewer/issues).

When **SBML Viewer** is helpful:

* You cannot install you favorite tool to read and check some SBML file right now.
* Your software cannot read some specific SBML versions or elements like <code>event</code>, <code>constraint</code> or <code>functionDefinition</code> etc. but the file includes them.
* You need to share your model in human readable format with someone easily.
* Your have some errors when reading foreign SBML and are trying to check the model code.

![sbmlviewer example](/assets/img/sbmlviewer_example.png)

# Quick start 
<hr/>

<div class="w3-btn w3-card-2 w3-green w3-circle w3-text-white"><a href="/{{ site.distPath }}viewer.xhtml" id="tryDemoLink">Try demo online</a></div>

For models from your computer:

1. Go to the page [http://sv.insysbio.ru/{{ site.distPath }}viewer.xhtml](/{{ site.distPath }}viewer.xhtml)
2. Click on button "Choose file" and select your sbml model.

For models shared on web:

1. Copy the link of your shared model, for instance <code>http://www.example.com/your_sbml_file.xml<code>
2. Write the line in your browser like this <code>http://sv.insysbio.ru/{{ site.distPath }}viewer.xhtml?http://www.example.com/your_sbml_file.xml<code>

## Examples
To look through example just try the links
* [test 00001 from SBML Test Suite Database](http://sv.insysbio.ru/{{ site.distPath }}viewer.xhtml?http://sv.insysbio.ru/cases/00001-sbml-l2v5.xml)
* [BIOMD0000000512 from BioModels Database, model of the month in January 2016](http://sv.insysbio.ru/{{ site.distPath }}viewer.xhtml?http://sv.insysbio.ru/cases/BIOMD0000000512.xml)
* [BIOMD0000000622 from BioModels Database, model of the month in January 2017](http://sv.insysbio.ru/{{ site.distPath }}viewer.xhtml?http://sv.insysbio.ru/cases/BIOMD0000000622.xml)
* [BIOMD0000000439 from BioModels Database, model of the month in October 2016](http://sv.insysbio.ru/{{ site.distPath }}viewer.xhtml?http://sv.insysbio.ru/cases/BIOMD0000000439.xml)

# Features
<hr/>

## Current release

- reading SBML Level 2 Version 1-5
- creating tabular view of model with: **sbml2table** transformation
- summary generation for chosen element: **sbml2element** transformation

## Known restrictions
- wrong representation of local <code>parameter</code> element inside <code>kineticLaw</code>
- ignores <code>annotation</code> elements for presentation

## Roadmap

- **sbml2tree** transformation
- **sbml2ode** transformation
- Transformation to Antimony format: **sbml2antimony** transformation
- Chrome extension for SbmlViewer

<hr/>
<a class="w3-btn w3-round w3-block w3-teal" href="http://eepurl.com/cL_5az">Subscribe to SbmlViewer updates <i class="fa fa-envelope w3-large"></i></a>

## Maintaners

- Viktoria Tkachenko @vetedde
- Evgeny Metelkin @metelkin

## License
Apache 2.0

## 3d party software used

- [MathJax](https://www.mathjax.org)
- [W3.CSS](http://www.w3schools.com/w3css/) 

## About SBML

SBML is a free and open interchange format for computer models of biological processes maintained by [SBML community](http://sbml.org/). It is used in many modeling application and can store model structure, math and annotation of elements. SBML is XML based format and designed basically for machine reading and writing.