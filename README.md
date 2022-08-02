# `img2pdf.coffee`

This is a [*CoffeeScript*](//coffeescript.org/) whitch creates PDF from image files (JPEG, PNG, JP2) without reencoding.
It was inspired by [img2pdf](//gitlab.mister-muffin.de/josch/img2pdf) Python script.
Use it with [`mutool run`](//mupdf.com/docs/manual-mutool-run.html) from [MuPDF](//mupdf.com/) toolkit.

`mutool` accepts only scripts written in *JavaScript* (ES5) so you must build one from [`img2pdf.coffee`](img2pdf.coffee) first.

# Requirements

* **NodeJS** - required only to build JavaScript from CoffeeScript.
* **MuPDF** toolkit.

# Building `js` script

1. Clone repository to any directory you like.
2. Run `npm install`

   This command installs all required packages.

3. Run `npm run build` (or `npm run build:dev`)
   
   This command generates `img2pdf.js` script in `public` subfolder.
   It is minified by *WebPack*.
   
# Usage

`img2pdf` accepts only one parameter - path to configuration file.
Configuration is described in **JSON** format.

Example:
```json
{
	"tmpDocPath": "c:\\temp\\~img2pdf-doc.pdf",
	"src": [
		"front.jpg",
		{"img": "img.jpg", "resolution": 1200},
		{"pdf": "pdf2.pdf"},
		{"doc": "svg1.svg", "scaleX": 5, "scaleY": 10},
		{"pdf": "pdf1.pdf"},
		{"img": ["img.jp2", "img.png"], "resolutionX": 300, "resolutionY": 400},
		{"doc": ["svg2.svg", "svg3.svg"], "scale": 5},
	],
	"output": "images.pdf",
	"outputOpts": ["sanitize"],
	"info": {
		"author": "Author",
		"producer": "mu-img2pdf",
		"title": "This is my super complex title",
		"creationDate": [],
		"modDate": [],
	}
}
```
`tmpDocPath` element is **mandatory** if you want to import/convert SVG documents.
It is a path to temporary PDF document with rendered SVG document.

Empty array `[]` in `info.creationDate` and `info.modDate` elements means *current timestamp*.

After preparing configuration file run `mutool`:
```sh
mutool run img2pdf.js cfg.json
```

# Links

* [img2pdf](//gitlab.mister-muffin.de/josch/img2pdf)
* [MuPDF](//mupdf.com/index.html)
* [MuPDF at GitHub](//github.com/ArtifexSoftware/mupdf)
* [CoffeeScript](//coffeescript.org/)
* [WebPack](//webpack.js.org/)
