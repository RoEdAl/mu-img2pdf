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
	"src": [
		"front.jpg",
		{"img": "00-01.jpg", "resolution": 1200},
		{"pdf": "test2.pdf"},
		{"pdf": "test1.pdf"},
		{"img": "02-03.jp2", "resolutionX": 300, "resolutionY": 400}
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
Empty array `[]` for `info.creationDate` and `info.modDate` means *current timestamp*.

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
