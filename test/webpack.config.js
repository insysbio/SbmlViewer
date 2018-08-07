const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  devServer: {
    port: 8081,
    progress: true,
    contentBase: './',
    watchContentBase: true
  },
  context: path.resolve(__dirname, '../'),
  entry: {
    app: './test/app.js'
  },
  output: {
    path: path.resolve(__dirname, ''),
    filename: '[name].js'
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: 'test/index.html'
    })
  ],
  module: {
    rules: [
      {
        test: /\.(xsl)|(xml)$/,
        use: 'raw-loader'
      }
    ]
  }
};
