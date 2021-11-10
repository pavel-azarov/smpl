# How to run Component-tests in Account Management Service 
Current project supported npm version - `6.14.4`

The component tests for the Account Management service are written using [Cucumber.js](https://github.com/cucumber/cucumber-js), with 
[Typescript](https://www.typescriptlang.org/).

We also use the [cucumber-tsflow](https://github.com/timjroberts/cucumber-js-tsflow) package for class based state encapsulation.

Linting is performed with [Es-Lint](https://eslint.org/), and we use [Prettier](https://prettier.io/) to format the code.

Linting and format errors are enforced on the pipeline and will fail if not corrected.

## Yarn Scripts

| Command               | Description                                                      |
|-----------------------|------------------------------------------------------------------|
| yarn test             | Runs component tests                                             |
| yarn test-tag TAGNAME | Runs component tests for TAGNAME                                 |
| yarn lint             | Runs an es-lint check                                            |
| yarn lint-fix         | Runs an es-lint fix, automatically correcting any linting errors |
| yarn format           | Runs prettier to check if format of code is correct              |
| yarn format-fix       | Runs prettier to correct any formatting issues                   |

### Prerequisites

---
Run the command `npm install` under "component-tests" for packages & dependencies installation.

### Running CucumberJS using "Command line"

---

To run tests you need to be in the directory `(home directory)/gateway.svc.molt.in/component-tests`

Running the whole test suite
- execute the command - `npm test`

Running a specific cucumber feature file
- execute the command - `npm test features/(FileName).feature`
    - ex. `npm test features/account-create.feature`

Running a specific annotation feature tag

#####Option 1
- execute the command - `node_modules/.bin/cucumber-js --tags @tag_feature`

#####Option 2
- execute the command - `yarn test-tag @(tag_feature)`

To run the component tests outside of the `component-test` directory
```shell script
make component-test
```

### Running CucumberJS using "IntelliJ" IDE

---

In order for CucumberJS to function properly, you will need to download the plugin `cucumber.js` from intellj's marketplace settings.

- `* NOTE *` - You can also download the plugin from Jetbrains site - https://plugins.jetbrains.com/plugin/7418-cucumber-js

Import the project as an `empty project`

There are two options to run cucumber feature file when using an IDE

#####Option 1
* `* NOTE *` - Running tests when only one cucumber plugin is installed or disable other cucumber plugins
1. Open up the `features` directory in the project window of IntelliJ
2. `Right click` on the feature file
3. Go to `Run (feature file name).feature`

Running the whole test suite
1. Right click the `features` directory in the project window of IntelliJ
2. Click `Run features`

#####Option 2
* `* NOTE *` - Running tests when multiple plugins are installed in IntelliJ
1. Go to `Add Configuration` near the top right of the IntelliJ IDE
2. Click the `+` icon in the window
3. Select `CucumberJS`
4. In the `Feature file or Directory` input the file path of where the feature file is
    - ex. `(home directory)/gateway.svc.molt.in/component-tests/features`
5. Select the cucumber runner configuration you have just created
6. `Right click` on the feature file
7. Go to `Run` -> `(feature file name).feature`
