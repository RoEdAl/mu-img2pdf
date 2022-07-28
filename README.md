# `img2pdf.coffee`

This is a [*CoffeeScript*](//coffeescript.org/) whitch creates PDF from image files (JPEG, PNG) without reencoding.
It was inspired by [img2pdf](//gitlab.mister-muffin.de/josch/img2pdf) Python script.
Use it with [`mutool run`](//mupdf.com/docs/manual-mutool-run.html) from [MuPDF](//mupdf.com/) toolkit.

`mutool` accepts only scripts written in JavaScript (ES5) so you must build one from [`img2pdf.coffee`](img2pdf.coffee) first.

# Requirements

* **NodeJS** - required only to build JavaScript from CoffeeScript.
* **MuPDF** toolkit.

# Building `js` script

1. Clone repository to any directory you like.
2. Run `npm install`

   This command installs all required packages.

3. Run `npm run build` (or `npm run build:dev`)
   
   This command generates `img2pdf.js` script in `public` subfolder.
   It is minified by *WebPack* so rather not human readable.
   
# Usage

`img2pdf` accepts only one parameter - path to configuration file.
Configuration is described in **JSON** format.
Example configuration file you can find [here](cfg-example.json).

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
