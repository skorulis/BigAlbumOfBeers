const fs = require("fs")


let raw = JSON.parse(fs.readFileSync("./js/raw.json"));
let extra = JSON.parse(fs.readFileSync("./js/extra.json"));

console.log(raw)