title: Contributing
---
We welcome you to join the development of Moleculer. This document will help you through the process.

## Before You Start

Please follow the coding style:
- Use tabs with size of 4 for indents.
- Always use strict mode & commas.
- Use double quotes.

## Contribute to core modules

Follow this workflow if you would like to modify the core modules.

### Workflow

1. Fork the [ice-services/moleculer](https://github.com/ice-services/moleculer) repo.
2. Clone the repository to your computer and install dependencies.

    ```bash
    $ git clone https://github.com/<username>/moleculer.git
    $ cd moleculer
    $ npm install
    ```

3. Start Moleculer in dev mode

    ```bash
    $ npm run dev
    ```

    or in continuous test mode

    ```bash
    $ npm run ci
    ```

4. Fix the bug or add a new feature.
5. Run tests & check the coverage report.

    ```bash
    $ npm test
    ```

    > If you added new features, please add relevant new test cases!

    {% note info %}
    Your pull request will only get merged when tests passed and covered all codes. Don't forget to run tests before submission.
    {% endnote %}


6. Commit & push the branch.

7. Create a pull request and describe the change.

## Contribute to create a new Moleculer module

Follow this workflow if you would like to create a new module for Moleculer

### Workflow

1. Install the command-line tool.
    ```bash
    $ npm install moleculer-cli -g
    ```

2. Create a new module skeleton (named `moleculer-awesome`).
    ```bash
    $ moleculer init module moleculer-awesome
    ```

3. Edit `src/index.js` and implement the logic.

4. For developing use the `dev` mode (it starts your module with `example/simple/index.js`)

    ```bash
    $ npm run dev
    ```

    or continuous test mode

    ```bash
    $ npm run ci
    ```

4. Create tests in `test/unit/index.spec.js` & cover the full source.

    ```bash
    $ npm test
    ```

5. If it's done and you think it will be useful many developers [tell us!](https://github.com/ice-services/moleculer/issues)

## Reporting Issues

When you encounter some problems when using Moleculer, you can find the solutions in [FAQ](faq.html) or ask us on [Gitter](https://gitter.im/ice-services/moleculer). If you can't find the answer, please report it on [GitHub Issues](https://github.com/ice-services/moleculer/issues).
