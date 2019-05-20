const rp = require("request-promise");
// Travis don't like fsPromises
// const fsPromises = require("fs").promises;
const fs = require("fs");
const util = require("util");
const writeFile = util.promisify(fs.writeFile);

const URL = `https://raw.githubusercontent.com/AndreMaz/awesome-moleculer/master/out/site_modules.yml`;

// Path to modules
const DIR_TO_WRITE = `source/_data/modules.yml`;

async function fetchModules() {
    try {
        // HTTP GET yaml file as string
        const payload = await rp.get(URL);

        await writeFile(DIR_TO_WRITE, payload);
    } catch (error) {
        throw error;
    }
}

fetchModules();
