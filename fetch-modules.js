const rp = require("request-promise");
const fs = require("fs");
const util = require("util");
const writeFile = util.promisify(fs.writeFile);

// URL pointing to new modules
const URL = `https://raw.githubusercontent.com/moleculerjs/awesome-moleculer/master/out/site_modules.yml`;

// Path to modules
const DIR_TO_WRITE = `source/_data/modules.yml`;

async function fetchModules() {
    try {
        // HTTP GET yaml file as a string
        const payload = await rp.get(URL);

        await writeFile(DIR_TO_WRITE, payload);
    } catch (error) {
        console.log(error);
		process.exit(1);
    }
}

fetchModules();
