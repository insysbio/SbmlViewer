/* global window */

const parser = new window.DOMParser();

let xsltCollection = require('./index')(parser);

window.xsltCollection = xsltCollection;
