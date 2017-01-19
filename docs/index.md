*The page is under development*

# SBML Viewer
**SBML Viewer** is a tool for fast and easy reading models written in SBML format. It allows looking through model components and equations even if you have no modeling software installed. It is as simple as reading a web page in your web browser.

When **SBML Viewer** is helpful:

* You have no facilities to install you favorite tool to read and check some SBML file right now.
* Your software cannot read some specific SBML versions or elements like "event", "constraint" or "functionDefinition" etc. but the file includes them.
* You need to share your model in human readable format with someone easily.
* Your have some errors when reading foreign SBML and are trying to check the structure.

## About SBML
SBML is a free and open interchange format for computer models of biological processes, see [SBML community portal](http://sbml.org/). It is used in many modeling application and can store model structure, math and annotation of elements. SBML is XML based format and designed basically for machine reading and writing.

# Quick start
Web accessible files:

1. Share your sbml file in web, for example on <code>http://www.example.com/your_sbml_file.xml<code>
2. Write the line in your favorite browser <code>http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://www.example.com/your_sbml_file.xml<code>

Locally accessible files:

# Examples
To look through example just try the links

* [first example](http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://www.example.com/your_sbml_file.xml)
* [second example](http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://www.example.com/your_sbml_file.xml)
* [third example](http://sbmlviewer.insilicobio.ru/viewer.xhtml?http://www.example.com/your_sbml_file.xml)

# Releases

## Current release

- reading SBML Level 2 Version 1-5
- creating tabular view of model with: **sbml2table** transformation
- summary generation for chosen element: **sbml2element** transformation

## Known restrictions

- 

## Roadmap

- Chrome extension
- Transformation to Antimony format: **sbml2antimony** transformation
- **sbml2report** transformation
- **sbml2tree** transformation

# Other information

## Subscribe for updates

[Subscription](http://eepurl.com/cxCiu5)

## Authors

- Evgeny Metelkin

## License
MIT License

## Many thanks to developers

- [MathJax](https://www.mathjax.org)
- [W3.CSS](http://www.w3schools.com/w3css/) 
