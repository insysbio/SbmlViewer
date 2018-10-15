/**
 * Read file and return content of file in format XML-DOM
 *
 * @param {object} file - file of model(object File)
 */
export function readXmlUpload (file, callback) {
  const reader = new FileReader()

  reader.onload = function () {
    try {
      let parsedDoc = new DOMParser()
        .parseFromString(reader.result, 'application/xml')
      callback(null, parsedDoc)
    } catch (err) {
      callback(err, null)
    }
  }

  reader.readAsText(file)
};
