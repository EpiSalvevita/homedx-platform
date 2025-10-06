module.exports = {
  presets: ['@babel/env', '@babel/react'],
  plugins: [
    ['@babel/plugin-transform-runtime'],
    [
      'module-resolver',
      {
        root: ['./src'],
        extensions: [
          '.ios.ts',
          '.android.ts',
          '.ts',
          '.ios.tsx',
          '.android.tsx',
          '.tsx',
          '.jsx',
          '.js',
          '.json'
        ],
        alias: {
          Network: './src/Network.js',
          Style: './src/style/index.scss',
          Language: './src/Language.js',
          Utility: './src/Utility.js',
          Store: './src/Store.js',
          screens: './src/screens',
          components: './src/components',
          base: './src/base',
          assets: './src/assets',
          services: './src/services',
          'hdx-config': './hdx.config.js'
        }
      }
    ]
  ]
}
