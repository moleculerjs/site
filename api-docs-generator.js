/* eslint-disable no-console */
"use strict";

const documentation = require("documentation");
const fs = require("fs");
const path = require("path");
const _ = require("lodash");
const semver = require("semver");
const mkdir = require("mkdirp").sync;
const Promise = require("bluebird");

/**
 * Check this section is a `Function`
 * 
 * @param {any} section 
 * @returns 
 */
function isFunction(section) {
	return (
		section.kind === "function" ||
		(section.kind === "typedef" &&
			section.type.type === "NameExpression" &&
			section.type.name === "Function")
	);
}

/**
 * Format parameters for signature
 * 
 * @param {any} section 
 * @param {any} short 
 * @returns 
 */
function formatParameters(section, short) {
	if (section.params) {
		let res = section.params.map(param => formatParameter(param, short)).join(", ");
		return `(${res})`;
	}
	return "()";
}

/**
 * Format a parameter for signature
 * 
 * @param {any} param 
 * @param {any} short 
 * @returns 
 */
function formatParameter(param, short) {
	if (short) {
		if (param.type && param.type.type == "OptionalType") {
			if (param.default) {
				return param.name + " = " + param.default;
			}
			return param.name + "?";
		}
		return param.name;
	}
	if (param.type && param.type.name)
		return param.name + ": " + param.type.name.replace(/\n/g, "");
	
	return param.name;
}

// Read package.json to get API version number
const pkg = require("moleculer/package.json");
const apiVersion = semver.major(pkg.version) + "." + semver.minor(pkg.version);
console.log("API version:", apiVersion);

// Source files for API docs
const sourceFiles = [
	{ path: "service-broker.js", name: "ServiceBroker" },
	{ path: "service.js", name: "Service" },
	{ path: "context.js", name: "Context" }
]

// Target folder
const targetFolder = path.join(".", "source", "api-" + apiVersion);
console.log("Target folder:", targetFolder);
mkdir(targetFolder);

// Template
const templateFolder = path.join(__dirname, "api-template", "md");
const template = _.template(fs.readFileSync(path.join(templateFolder, "index.md"), "utf8"));
const paramTemplate = _.template(fs.readFileSync(path.join(templateFolder, "params.md"), "utf8"));
const membersTemplate = _.template(fs.readFileSync(path.join(templateFolder, "members.md"), "utf8"));


Promise.each(sourceFiles, sourceFile => {

	let f = path.join(__dirname, ".", "node_modules", "moleculer", "src", sourceFile.path);

	let sharedImports = {
		title: sourceFile.name,
		apiVersion,

		getTag(p, tags) {
			let res = tags.find(t => t.lineNumber == p.lineNumber);
			return res;
		},

		getDesc(p) {
			if (p.children.length > 0) {
				let pp = p.children[0];
				if (pp.type == "paragraph" && pp.children.length > 0) {
					return pp.children[0].value;
				}
			}
		},

		hasValidParam(params, tags) {
			if (params.length > 0) {
				return params.filter(p => tags.find(t => t.lineNumber == p.lineNumber) != null).length > 0;
			}

			return false;
		},

		signature(section) {
			let returns = "";
			let prefix = "";
			if (section.kind === "class") {
				prefix = "new ";
			} else if (section.name == "constructor") {
				return `new ${section.memberof}${formatParameters(section)}`;
			} else if (!isFunction(section)) {
				return section.name;
			}
			if (section.returns.length && section.returns[0].type) {
				returns = ": " + section.returns[0].type.name;
			}
			return prefix + section.name + formatParameters(section) + returns;
		}
	};

	sharedImports.renderParams = (params, tags) => paramTemplate(Object.assign({
		params,
		tags
	}, sharedImports));

	sharedImports.renderMembers = (members) => membersTemplate(Object.assign({
		members
	}, sharedImports));

		



	return documentation.build([f], {
		//access: ["public"]
		shallow: true,
		inferPrivate: '^_'
	}).then(docs => {
		const markdown = template(Object.assign({ docs }, sharedImports));

		fs.writeFileSync(path.join(targetFolder, sourceFile.path.replace(/\.[^/.]+$/, ".md")), markdown, "utf8");

		console.log(`Done '${sourceFile.path}'!`);
	}).catch(err => console.error(err))
	
}).then(() => {
	/*console.log(`Copy PROTOCOL.md...`);
	let content = fs.readFileSync(path.join(__dirname, ".", "node_modules", "moleculer", "docs", "PROTOCOL.md"), "utf8");
	fs.writeFileSync(path.join(targetFolder, "protocol.md"), content, "utf8");
	*/
}).then(() => {
	console.log(`Create index.md...`);
	if (!fs.existsSync(path.join(targetFolder, "index.md")))
		fs.writeFileSync(path.join(targetFolder, "index.md"), "", "utf8");
	
}).then(() => {
	console.log("All files done!");
	process.exit(0);
});

