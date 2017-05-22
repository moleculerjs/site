# Moleculer official website

This is the official website of Moleculer project. This site is built with [hexo](https://hexo.io/). Site content is written in Markdown format and located in `source`.

# Development

```bash
$ git clone git@github.com:ice-services/ice-services.github.io.git
$ cd ice-services.github.io
$ npm install
$ npm run dev
```

# Generate static files

```bash
$ npm run build
```

# Want to help with the translation?

If you want to help us to translate Moleculer website & documentation to your language, just fork the repo, create a "work-in-progress" issue to inform others that you're doing the translation, and just go on.

**Which files do I need to translate?**
1. Copy the `en.yml` in `/themes/moleculer/languages` and rename to the language name (all lower case. E.g.: `fr.yml`)
2. Add a new language folder in `source` folder. (All lower case. E.g.: `/source/fr`)
3. Copy the files from `/source/api` & `/source/docs` to the new language folder (`/source/fr/api`, `/source/fr/docs`)
4. Add the new language to `/source/_data/languages.yml`
5. Start the translating :)
6. If you are ready, open a PR.

Thank you in advance!

# Contact
Copyright (c) 2016-2017 Ice-Services

[![@icebob](https://img.shields.io/badge/github-ice--services-green.svg)](https://github.com/ice-services) [![@icebob](https://img.shields.io/badge/twitter-MoleculerJS-blue.svg)](https://twitter.com/MoleculerJS)
