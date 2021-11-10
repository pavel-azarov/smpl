// eslint-disable-next-line @typescript-eslint/no-var-requires,no-undef
const reporter = require('cucumber-html-reporter')
//themes: 'bootstrap', 'hierarchy', 'foundation', 'simple'
const options = {
  theme: 'bootstrap',
  jsonFile: 'report/component-tests-report.json',
  output: 'report/component-tests-report.html',
  reportSuiteAsScenarios: true,
  scenarioTimestamp: true,
  launchReport: true,
  columnLayout: 1,
  metadata: {
    'Test Environment': 'LOCAL',
  },
}

reporter.generate(options)
