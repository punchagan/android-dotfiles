const { Readability } = require("@mozilla/readability");
const { JSDOM } = require("jsdom");
const axios = require("axios");

const url = process.argv[2];
if (!url) {
  console.error("Please pass a URL as an argument.");
  process.exit();
}

axios.get(url).then((response) => {
  const doc = new JSDOM(response.data, { url });
  const reader = new Readability(doc.window.document);
  const article = reader.parse();
  console.log(article.content);
});
