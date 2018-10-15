
**SbmlViewer** is a tool for fast and easy reading biological models written in SBML format. It allows looking through model components and equations even if you have no modeling software installed. It is as simple as reading a web page in your web browser.

SbmlViewer never uploads your files to the server and all transformations are performed locally in your browser, so it is safe and secure for your code.

SbmlViewer is open project located on [GitHub](https://github.com/insysbio/SbmlViewer). Any feedback is welcomed on [Issues page](https://github.com/insysbio/SbmlViewer/issues).

When **SbmlViewer** is helpful:

* You cannot install you favorite tool to read and check some SBML file right now.
* Your software cannot read some specific SBML versions or elements like <code>event</code>, <code>constraint</code> or <code>functionDefinition</code> etc. but the file includes them.
* You need to share your model in human readable format with someone easily.
* Your have some errors when reading foreign SBML and are trying to check the model code.

![sv scren 1](/assets/img/sv_screen1.png)

# Quick start
<hr/>

<div class="w3-btn w3-card-2 w3-green w3-circle w3-text-white"><a href="{{ site.distPath }}" id="tryDemoLink">Try demo online</a></div>

For models from your computer:

1. Go to the page [http://sv.insysbio.com/{{ site.distPath }}](/{{ site.distPath }})
2. Drug'n'drop your SBML OR click on button "Choose file" and select your sbml model.

For models shared on web:

1. Copy the link of your shared model, for instance http://www.example.com/your_sbml_file.xml
2. Write the line in your browser like this http://sv.insysbio.com/{{ site.distPath }}?http://www.example.com/your_sbml_file.xml

## Examples
To look through example just try the links
* [test 00001 from SBML Test Suite Database](http://sv.insysbio.com/{{ site.distPath }}?http://sv.insysbio.com/cases/00001-sbml-l2v1.xml)
* [BIOMD0000000512 from BioModels Database, model of the month in January 2016](http://sv.insysbio.com/{{ site.distPath }}?http://sv.insysbio.com/cases/BIOMD0000000512.xml)
* [BIOMD0000000588 from BioModels Database, model of the month in February 2017](http://sv.insysbio.com/{{ site.distPath }}?http://sv.insysbio.com/cases/BIOMD0000000588.xml)
* [BIOMD0000000439 from BioModels Database, model of the month in October 2016](http://sv.insysbio.com/{{ site.distPath }}?http://sv.insysbio.com/cases/BIOMD0000000439.xml)


![sv scren 2](/assets/img/sv_screen2.png)

# Features
<hr/>

## Current release

Version: 170622

- reading SBML Level 2 Version 1-5
- reading SBML Level 3 Version 1-2
- creating tabular view of model with: **sbml2table** or **sbml3table** transformation
- summary generation for chosen element: **sbml2element** or **sbml3element** transformation
- generation of equation corresponding to your model: **sbml2math** transformation


<hr/>

## Team

- Viktoria Tkachenko @vetedde
- Evgeny Metelkin @metelkin

## License
Apache 2.0

## 3d party software used

- [MathJax](https://www.mathjax.org)
- [W3.CSS](http://www.w3schools.com/w3css/)

## About SBML

SBML is a free and open interchange format for computer models of biological processes maintained by [SBML community](http://sbml.org/). It is used in many modeling application and can store model structure, math and annotation of elements. SBML is XML based format and designed basically for machine reading and writing.
