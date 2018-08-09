/* eslint-disable */
'use strict';
const sbml2tableText = require('./sbml2table.xsl');
const sbml2mathText = require('./sbml2math.xsl');
const sbml2elementText = require('./sbml2element.xsl');

const sbml3tableText = require('./sbml3table.xsl');

module.exports = function(parser){
  let sbml2table = parser.parseFromString(sbml2tableText, 'application/xml');
  let sbml2math = parser.parseFromString(sbml2mathText, 'application/xml');
  let sbml2element = parser.parseFromString(sbml2elementText, 'application/xml');

  let sbml3table = parser.parseFromString(sbml3tableText, 'application/xml');

  return [
    {
      format: 'SBML',
      level: '2',
      name: 'sbml2table',
      xslt: sbml2table,
      parameters: ['useNames', 'correctMathml', 'equationsOff']
    },
    {
      format: 'SBML',
      level: '2',
      name: 'sbml2math',
      xslt: sbml2math,
      parameters: ['useNames', 'correctMathml', 'equationsOff']
    },
    {
      format: 'SBML',
      level: '2',
      name: 'sbml2element',
      xslt: sbml2element,
      parameters: ['useNames', 'correctMathml', 'equationsOff', 'elementId']
    },
    {
      format: 'SBML',
      level: '3',
      name: 'sbml3table',
      xslt: sbml3table,
      parameters: ['useNames', 'correctMathml', 'equationsOff']
    }
  ];
};
