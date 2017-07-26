/* eslint-disable no-console */
"use strict";

const documentation = require("documentation");
const fs = require("fs");
const path = require("path");
const pug = require("pug");
const semver = require("semver");
const marked = require("marked");
const hljs = require("highlight.js");
const mkdir = require("mkdirp").sync;
const Promise = require("bluebird");

const template = pug.compileFile(path.join(__dirname, "api-template", "index.pug"), {
	pretty: true,
	//debug: true
});

function isFunction(section) {
	return (
		section.kind === "function" ||
		(section.kind === "typedef" &&
			section.type.type === "NameExpression" &&
			section.type.name === "Function")
	);
}

function formatParameters(section, short) {
	if (section.params) {
		let res = section.params.map(param => formatParameter(param, short)).join(", ");
		return `(${res})`;
	}
	return "()";
}

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

function codeHighlight(code) {
	return "<pre class='hljs'>" + hljs.highlightAuto(code, "js") + "</pre>";
}

const pkg = require("moleculer/package.json");

const apiVersion = semver.major(pkg.version) + "." + semver.minor(pkg.version);

console.log("API version:", apiVersion);

const sourceFiles = [
	{ path: "service-broker.js", name: "ServiceBroker" },
	{ path: "service.js", name: "Service" },
	{ path: "context.js", name: "Context" }
]

const targetFolder = path.join(".", "source", "api-" + apiVersion);
console.log("Target folder:", targetFolder);

mkdir(targetFolder);

Promise.each(sourceFiles, sourceFile => {

	let f = path.join(__dirname, ".", "node_modules", "moleculer", "src", sourceFile.path);
	return documentation.build([f], {
		//access: ["public"]
		shallow: true,
		inferPrivate: '^_'
	}).then(docs => {
		const html = template({
			docs,
			title: "Context API documentation",
			apiVersion,

			md: marked,
			getTag: (p, tags) => {
				let res = tags.find(t => t.lineNumber == p.lineNumber);
				return res;
			},

			getDesc: p => {
				if (p.children.length > 0) {
					let pp = p.children[0];
					if (pp.type == "paragraph" && pp.children.length > 0) {
						return pp.children[0].value;
					}
				}
			},

			hasValidParam: (params, tags) => {
				if (params.length > 0) {
					return params.filter(p => tags.find(t => t.lineNumber == p.lineNumber) != null).length > 0;
				}

				return false;
			},

			signature: section => {
				let returns = "";
				let prefix = "";
				if (section.kind === "class") {
					prefix = "new ";
				} else if (!isFunction(section)) {
					return section.name;
				}
				if (section.returns.length && section.returns[0].type) {
					returns = ": " + section.returns[0].type.name;
				}
				return prefix + section.name + formatParameters(section) + returns;
			},
			highlight: code => hljs.highlight("js", code).value
		});

		fs.writeFileSync(path.join(targetFolder, sourceFile.path.replace(/\.[^/.]+$/, ".html")), html, "utf8");

		console.log(`Done '${sourceFile.path}'!`);
	}).catch(err => console.error(err))
	
}).then(() => {
	console.log("All files done!");
	process.exit(0);
});

