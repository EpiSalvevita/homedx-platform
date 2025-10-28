module.exports = {
  root: true,
  extends: ['plugin:prettier/recommended'],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'prettier'],
  overrides: [
    {
      files: ['*.ts', '*.tsx'],
      rules: {
        'prettier/prettier': 'error',
        '@typescript-eslint/no-shadow': ['error'],
        'no-undef': 'off',
        'no-shadow': false,
        'eol-last': ['off'],
        'no-use-before-define': 'off',
        'react-native/no-inline-styles': ['off'],
        // 'react-hooks/rules-of-hooks': 'error',
        // 'react-hooks/exhaustive-deps': 'warn',
        'no-unused-expressions': 'off'
      }
    }
  ]
}
