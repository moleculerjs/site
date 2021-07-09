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

1. Faça o fork do repositório [moleculerjs/moleculer](https://github.com/moleculerjs/moleculer).
2. Clone o repositório para o seu computador e instale dependências.

    ```bash
    $ git clone https://github.com/<username>/moleculer.git
    $ cd moleculer
    $ npm install
    ```

3. Inicie Moleculer no modo de desenvolvimento

    ```bash
    $ npm run dev
    ```

    ou em modo de teste contínuo

    ```bash
    $ npm run ci
    ```

4. Corrija o bug ou adicione um novo recurso.
5. Execute testes & verifique o resultado.

    ```bash
    $ npm test
    ```

    > Se você adicionou novos recursos, por favor, adicione novos casos de teste relevantes! Nosso objetivo é a cobertura 100%.

    {% note info %}
    Seu pull request somente será implementado quando os testes passem e cubram todo o código. Não esqueça de executar testes antes do envio.
    {% endnote %}

6. Execute o commit & push da branch.

7. Crie um pull request e descreva a mudança.

8. Se você mudou alguma API, atualize a [documentação](https://github.com/moleculerjs/site) também.

## Contribuição para criar um novo módulo Moleculer

Siga este fluxo se quiser criar um novo módulo para o Moleculer

### Workflow

1. Instale a ferramenta de linha de comando.
    ```bash
    $ npm install moleculer-cli -g
    ```

2. Crie um novo módulo (chamado `de moleculer-awesome`) a partir de um template padrão.
    ```bash
    $ moleculer init module moleculer-awesome
    ```

3. Edite `src/index.js` e implemente a lógica.

4. Em desenvolvimento, use o modo `dev` (inicia seu módulo com `example/simple/index.js`)

    ```bash
    $ npm run dev
    ```

    ou em modo de teste contínuo

    ```bash
    $ npm run ci
    ```

5. Crie testes em `test/unit/index.spec.js` & cubra completamente o código.

    ```bash
    $ npm test
    ```

6. Se isso for feito e você acha que será útil para outros usuários, [conte pra nós!](https://github.com/moleculerjs/moleculer/issues)

## Reportando problemas

Quando você encontrar alguns problemas ao usar Moleculer, você pode encontrar soluções no [FAQ](faq.html) ou nos perguntar no [Discord](https://discord.gg/TSEcDRP) ou no [StackOverflow](https://stackoverflow.com/questions/tagged/moleculer). Se você não consegue encontrar a resposta, por favor, reporte-o em [Problemas no GitHub](https://github.com/moleculerjs/moleculer/issues).

Muito obrigado!
