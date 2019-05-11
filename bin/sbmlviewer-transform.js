#!/usr/bin/env node
const commander = require('commander')
const fs = require('fs')
const executive = require('executive')
var libxslt = require('libxslt')
// const xmlParse = require('xslt-processor').xmlParse
const DOMParser = require('xmldom').DOMParser

commander
  .description('Transform sbml-file to html table')
  .usage('[inputFile]')
  .usage('[outputFile]')
  .option('-n, --useNames', 'Use "names" attribute instead of "id" attribute. Turn on the option for models with very long or uninformative ids')
  .option('-m, --correctMathml', 'Make some correction for MathML generated by SimBiology. Some of SimBiology models generate wrong MathML. Try this option if something looks wrong in equations.')
  .option('-e, --equationsOff', 'Use this option if you are not interested in math. It reduces time of transformation.')
  .action((input, output, cmd) => {
    // read sbml file
    try {
      var sbml = fs.readFileSync(input, 'utf8')
    } catch (e) {
      process.stderr.write(e.message)
      process.exit(0)
    }

    let level = new DOMParser()
      .parseFromString(sbml)
      .getElementsByTagName('sbml')[0]
      .getAttribute('level')

    // read xslt file
    try {
      var xslt = fs.readFileSync(`./src/sbml-to-xhtml/sbml${level}table.xsl`, 'utf8')
    } catch (e) {
      process.stderr.write(e.message)
      process.exit(0)
    }

    // transfrom sbml to xml
    libxslt.parse(xslt, (err, stylesheet) => {
      if (err) {
        process.exit(0)
        process.stderr.write(err.message)
      }

      // set params
      let params = ['useNames', 'correctMathml', 'equationsOff']
      params.forEach((flag) => {
        params['useNames'] = cmd && !!cmd['useNames']
      })

      // transform
      stylesheet.apply(sbml, params, (err, result) => {
        if (err) {
          process.exit(0)
          process.stderr.write(err.message)
        }

        // set path to output anr run build with the path
        process.env.OUTPUT_DEMO = output
        executive(`npm run build`)
          .then(() => {
            // read template file
            try {
              var template = fs.readFileSync(output + '/index.html', 'utf8')
            } catch (e) {
              process.stderr.write(e.message)
              process.exit(0)
            }
            result = result.replace('<title/>', '<title></title>') // incorrect notes. need fix. because now note does not visible

            result = template.replace('<div id="sv-hidden-content"></div>', `<div id="sv-hidden-content">${result}</div>`) // append result of transform
            fs.writeFile(output + '/index.html', result, (err) => { // rewrite index file
              if (err) throw err
              process.stdout.write(`Result successfully written to file: ${output}.`)
            })
          }

          )
      })
    })
  })
  .parse(process.argv)
