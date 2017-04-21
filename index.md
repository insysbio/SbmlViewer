# SBML Viewer
<hr/>
**SBML Viewer** is a tool for fast and easy reading models written in SBML format. It allows looking through model components and equations even if you have no modeling software installed. It is as simple as reading a web page in your web browser.

SBML Viewer never uploads your files to server and all transformation are performed locally in your browser, so it is safe. It is free. 

When **SBML Viewer** is helpful:

* You have no facilities to install you favorite tool to read and check some SBML file right now.
* Your software cannot read some specific SBML versions or elements like "event", "constraint" or "functionDefinition" etc. but the file includes them.
* You need to share your model in human readable format with someone easily.
* Your have some errors when reading foreign SBML and are trying to check the structure.

## About SBML
SBML is a free and open interchange format for computer models of biological processes, see [SBML community portal](http://sbml.org/). It is used in many modeling application and can store model structure, math and annotation of elements. SBML is XML based format and designed basically for machine reading and writing.

# Quick start 
<hr/>
<div class="w3-btn w3-card-2 w3-green w3-circle w3-text-white"><a href="http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml" id="tryDemoLink">Try demo online</a></div>

Your model is available from web:

1. Your model is shared on <code>http://www.example.com/your_sbml_file.xml<code>
2. Write the line in your favorite browser <code>http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml?http://www.example.com/your_sbml_file.xml<code>

Your model is available locally:
1. The following [http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml](http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml)
2. Click on button "Choose file" and choose file

# Examples
To look through example just try the links
* [test 00001 from SBML Test Suite Database](http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/00001-sbml-l2v5.xml)
* [BIOMD0000000512 from BioModels Database, model of the month in January 2016](http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/BIOMD0000000512.xml)
* [BIOMD0000000622 from BioModels Database, model of the month in January 2017](http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/BIOMD0000000622.xml)
* [BIOMD0000000439 from BioModels Database, model of the month in October 2016](http://sbmlviewer.insilicobio.ru/{{ site.distPath }}viewer.xhtml?http://sbmlviewer.insilicobio.ru/cases/BIOMD0000000439.xml)

# Releases
<hr/>
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
<hr/>
## Subscribe for updates
<div class="w3-button w3-large w3-round w3-green w3-text-white" style="margin-left: 40px">
  <img src="http://sbmlviewer.insilicobio.ru/assets/img/subscrip.png">
<a href="http://eepurl.com/cxCiu5">Subscription</a>
</div>
## Let people know about us
<ul class="share-buttons">
  <li>
    <a href="https://www.facebook.com/sharer/sharer.php?u={{ site.url }}" title="Share on Facebook" target="_blank"><img alt="Share on Facebook" src="http://sbmlviewer.insilicobio.ru/assets/img/social/Facebook.svg"></a>
  </li>
  <li>
    <a href="https://twitter.com/intent/tweet?ref_src=twsrc%5Etfw&text={{ site.description }}&url={{ site.url }}" target="_blank" title="Tweet"><img alt="Tweet" src="http://sbmlviewer.insilicobio.ru/assets/img/social/Twitter.svg"></a>
  </li>
  <li>
    <a href="https://plus.google.com/share?url={{ site.url }}" target="_blank" title="Share on Google+">
      <img alt="Share on Google+" src="http://sbmlviewer.insilicobio.ru/assets/img/social/Google+.svg">
    </a>
  </li>
  <li>
    <a href="http://www.linkedin.com/shareArticle?mini=true&url={{ site.url }}&title={{ site.title }}&summary={{ site.description }}&source={{ site.url }}" target="_blank" title="Share on LinkedIn">
      <img alt="Share on LinkedIn" src="http://sbmlviewer.insilicobio.ru/assets/img/social/LinkedIn.svg">
    </a>
  </li>
  <li>
    <a href="mailto:?subject={{ site.title }}&body={{ site.description }} {{ site.url }}" target="_blank" title="Send email">
      <img alt="Send email" src="http://sbmlviewer.insilicobio.ru/assets/img/social/Email.svg">
    </a>
  </li>
</ul>

## Authors

- Evgeny Metelkin @metelkin
- Viktoria Tkachenko @vetedde

## License
Apache 2.0

## 3d party software

- [MathJax](https://www.mathjax.org)
- [W3.CSS](http://www.w3schools.com/w3css/) 
