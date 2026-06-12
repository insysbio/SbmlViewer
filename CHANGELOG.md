# Change Log

## 0.3.8

- Fix MathML rendering inconsistencies for SBML inputs that use different namespace styles
- Normalize MathML element emission in SBML 2/3 XSL transforms to avoid prefix-dependent formula rendering
- Reduce intermittent MathJax click-to-zoom runtime failures (`Error: restart`) by hardening MathJax font fallback configuration

## 0.3.7

- Recalculate the current transformation automatically when transformation options are changed
- Remove trailing commas from generated Heta dictionaries
- Migrate to Vue 3.5 and update related dependencies
- Migrate to Webpack 5 and update related dependencies

## 0.3.6

- Fix MathJax/static asset loading in development and production builds
- Add `persistent` and `initialValue` columns to SBML Level 3 event tables
- Show a clear error for malformed SBML/XML input
- Update and clean build dependencies
- Remove unused build packages and obsolete workflow steps
- Require Node.js >=22 and update CI/CD workflows to Node 24

## 0.3.5

- Deploy to Azure Static Web Apps + secure headers update
- Include step content to master branch

## 0.3.4

- Update GA property ID
- Node update to 18.x

## 0.3.3

- minor references fix
- security updates

## 0.3.2

- optimize build and performance
- security updates
