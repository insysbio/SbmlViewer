// const FileReader = require('filereader')
const DOMParser = require('dom-parser')

/** Read file and return content of file in format XML-DOM
* @param {object} f - file of model(object File)
*/
export function readXmlUpload (f, callback) {
  console.log('Read with help FileReader...')

  var reader = new FileReader()
  reader.readAsText(f)
  reader.onload = function () {
    try {
      console.log(' Success')
      callback(new DOMParser().parseFromString(reader.result, 'application/xml'))
    } catch (err) {
      console.error(' Err: ', err)
      // showErrMess('Cannot read the file')
    }
  }
};
