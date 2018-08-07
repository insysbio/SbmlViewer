/* global window */
'use strict';

const parser = new window.DOMParser();

const casesCollection = require('./index.js')(parser);
const xsltCollection = require('../src/sbml-to-xhtml/index.js')(parser);

function transform(
  caseDoc,
  transformation,
  parameters=[]
){
  // clear errors
  document.getElementById('errors').innerHTML = '';

  let processor = new window.XSLTProcessor();
  parameters.forEach((x) => {
    processor.setParameter(null, x.id, x.value);
  });

  processor.importStylesheet(transformation.xslt);
  let result = processor.transformToDocument(caseDoc);
  let resultDiv = document.getElementById('result');

  if(resultDiv.firstElementChild===null){
    resultDiv.appendChild(result.firstElementChild);
  }else{
    resultDiv.replaceChild(result.firstElementChild, resultDiv.firstElementChild);
  }

  MathJax.Hub.Queue(["Typeset", MathJax.Hub]); // restart MathJax
}

function getCasesMenu(){
  let menuDiv = document.getElementById('menu');
  Object.keys(casesCollection).forEach((caseName) => {
    let caseButton =  document.createElement('span');
    caseButton.textContent = caseName + ' | ';
    caseButton.addEventListener('click', () => getTransformationMenu(caseName));
    menuDiv.appendChild(caseButton);
  });
}

function getTransformationMenu(caseName){
  let caseDoc = casesCollection[caseName];
  let resultDiv = document.getElementById('result');
  let menu2Div = document.getElementById('menu2');

  if(resultDiv.hasChildNodes())
    resultDiv.innerHTML = '';
  if(menu2Div.hasChildNodes()){
    menu2Div.innerHTML = '';
  }

  // check xml, sbml, version
  let namespace = caseDoc.documentElement.namespaceURI;
  switch(namespace){
    case 'http://www.sbml.org/sbml/level2':
    case 'http://www.sbml.org/sbml/level2/version2':
    case 'http://www.sbml.org/sbml/level2/version3':
    case 'http://www.sbml.org/sbml/level2/version4':
    case 'http://www.sbml.org/sbml/level2/version5':
      xsltCollection
        .filter((x) => x.format==='SBML' && x.level==='2')
        .forEach((x) => {
          let formatButton = document.createElement('span');
          formatButton.textContent = x.name + ' | ';
          formatButton.addEventListener('click', () => {
            getParametersMenu(caseDoc, x);
          });
          menu2Div.appendChild(formatButton);
        });
      getParametersMenu(caseDoc, xsltCollection[0]);
      break;
    default:
      let errorDiv = document.getElementById('errors');
      errorDiv.innerHTML = `The XML with namespace "${namespace}" is not supported`;
  }
}

function getParametersMenu(caseDoc, transformation){
  let menu3 = document.getElementById('menu3');
  if(menu3.hasChildNodes())
    menu3.innerHTML = '';
  let parameters = [];
  transformation.parameters.forEach((parameterName) => {
    let parameterTitle = document.createElement('span');
    parameterTitle.textContent = '\t' + parameterName + ': ';
    menu3.appendChild(parameterTitle);

    let parameterValue = document.createElement('input');
    parameterValue.id = parameterName;
    menu3.appendChild(parameterValue);

    parameters.push(parameterValue);
  });

  let btn = document.createElement('button');
  btn.setAttribute('type', 'button');
  btn.textContent = 'Transform';
  btn.addEventListener('click', () => {
    transform(caseDoc, transformation, parameters);
  });
  menu3.appendChild(btn);

  transform(caseDoc, transformation); // default transformation without parameters
}

window.onload = function(){
  let defaultCaseName = 'superexample';
  getCasesMenu();
  getTransformationMenu(defaultCaseName);
};
