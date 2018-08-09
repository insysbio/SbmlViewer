const superexampleText = require('../cases/superexample-l2v4.xml');
const _01025_sbml_l2v4Text = require('../cases/01025-sbml-l2v4.xml');
const faahText = require('../cases/BIOMD0000000512.xml');
const failText = require('../cases/fail_l3v5.xml');
const fail0Text = require('../cases/fail0.xml');

// L3
const _00046_sbml_l3v1Text = require('../cases/00046-sbml-l3v1.xml');

module.exports = function(parser){
  return {
    superexample: parser.parseFromString(superexampleText, 'application/xml'),
    _01025_sbml_l2v4Text: parser.parseFromString(_01025_sbml_l2v4Text, 'application/xml'),
    faah: parser.parseFromString(faahText, 'application/xml'),
    fail: parser.parseFromString(failText, 'application/xml'),
    fail0: parser.parseFromString(fail0Text, 'application/xml'),
    _00046_sbml_l3v1: parser.parseFromString(_00046_sbml_l3v1Text, 'application/xml')
  };
};
