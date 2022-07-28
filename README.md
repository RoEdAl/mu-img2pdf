# img2pdf.coffee

This is a CoffeScript (JavaScript) whitch creates PDF from image files (JPEG, PNG) without reencoding.
It was inspired by [img2pdf](https://gitlab.mister-muffin.de/josch/img2pdf) Python script.
Use it with `mutool run` from [MuPdf](https://mupdf.com/) toolkit.

`mutool` accepts only scripts written in JavaScript (ES5). You must build it from [img2pdf.coffee](img2pdf.coffee) first.

# Requirements

* **NodeJS** - required only to build JavaScript from CoffeeScript.
* **MuPDF** toolkit.

# Building `js` script

1. Clone repository to any directory you like.
2. Run `npm install`

   This command installs all required packages.

3. Run `npm run build` (or `npm run build:dev`)
   
   This command generates `img2pdf.js` script in `public` subfolder.
   
# Usage

`img2pdf` accepts only one parameter - path to configuration file.
Configuration is described in **JSON** format.
Example configuration file you can find [here](cfg-example.json).

After preparing configuration file run `mutool`:
```sh
mutool run img2pdf.sh cfg.json
```
