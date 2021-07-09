title: Contribuições
---
Convidamos você a participar no desenvolvimento do Moleculer. Este documento ajuda ao longo do processo.

## Antes de começar

Siga o estilo de codificação:
- Use tabulação com tamanho 4 para indentação.
- Sempre use o modo estrito & ponto e vírgula.
- Use aspas duplas em vez de aspas simples.

## Contribuição nos módulos principais

Siga este fluxo se você quiser modificar os módulos principais.

### Workflow

1. Fork the [moleculerjs/moleculer](https://github.com/moleculerjs/moleculer) repo.
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

    > If you added new features, please add relevant new test cases! We aim to 100% cover.

    {% note info %}
    Your pull request will only get merged when tests passed and covered all codes. Don't forget to run tests before submission.
    {% endnote %}

6. Commit & push the branch.

7. Create a pull request and describe the change.

8. If you've changed APIs, update the [documentation](https://github.com/moleculerjs/site), as well.

## Contribution to create a new Moleculer module

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

4. For development use the `dev` mode (it starts your module with `example/simple/index.js`)

    ```bash
    $ npm run dev
    ```

    or the continuous test mode

    ```bash
    $ npm run ci
    ```

5. Create tests in `test/unit/index.spec.js` & cover the full source.

    ```bash
    $ npm test
    ```

6. If it's done and you think it will be useful for other users, [tell us!](https://github.com/moleculerjs/moleculer/issues)

## Reporting Issues

When you encounter some problems when using Moleculer, you can find the solutions in [FAQ](faq.html) or ask us on [Discord](https://discord.gg/TSEcDRP) or on [StackOverflow](https://stackoverflow.com/questions/tagged/moleculer). If you can't find the answer, please report it on [GitHub Issues](https://github.com/moleculerjs/moleculer/issues).

Thank you!
