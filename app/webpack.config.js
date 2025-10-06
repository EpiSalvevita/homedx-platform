const path = require('path')
const CopyPlugin = require('copy-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const Dotenv = require('dotenv-webpack')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
const ImageMinimizerPlugin = require('image-minimizer-webpack-plugin')

module.exports = {
  entry: './src/app.js',
  resolve: {
    extensions: ['.js', '.jsx', '.json', '.mjs'],
    alias: {
      'hdx-config': path.resolve(__dirname, 'src/hdx-config.js')
    }
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel-loader'
      },
      {
        test: /\.mjs$/,
        include: /node_modules/,
        type: 'javascript/auto'
      },
      {
        test: /\.mjs$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.(s[ca]ss|css)$/,
        use: [
          'style-loader',
          'css-loader',
          {
            loader: 'postcss-loader',
            options: {
              postcssOptions: {
                plugins: [require('autoprefixer')]
              }
            }
          },
          'sass-loader'
        ]
      },
      {
        test: /\.(?<!b64.)svg$/,
        exclude: /(node_modules|bower_components)/,
        use: ['@svgr/webpack']
      },
      {
        test: /\.b64.svg$/,
        exclude: /(node_modules|bower_components)/,
        use: ['url-loader']
      },
      {
        test: /\.(png|jpe?g)$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'url-loader'
      }
    ]
  },
  output: {
    path: path.resolve(__dirname, 'dist/'),
    filename: hash => 'app.js'
  },
  plugins: [
    new HtmlWebpackPlugin({ hash: true }),
    new CopyPlugin({
      patterns: [{ from: 'public', to: './' }]
    }),
    new Dotenv()
    // new ImageMinimizerPlugin({
    //   minimizerOptions: {
    //     plugins: [
    //       ['gifsicle', { interlaced: true }],
    //       ['jpegtran', { progressive: true }],
    //       ['optipng', { optimizationLevel: 5 }]
    //     ]
    //   }
    // })
  ],
  optimization: {
    minimizer: [
      new UglifyJsPlugin({
        test: /\.(js|jsx)$/,
        exclude: /(node_modules)/
      })
    ]
  },
  devServer: {
    host: '0.0.0.0',
    writeToDisk: true,
    contentBase: path.join(__dirname, 'dist'),
    compress: true,
    port: 3000,
    historyApiFallback: true
  },
  target: 'web' // Make web variables accessible to webpack, e.g. window
}
