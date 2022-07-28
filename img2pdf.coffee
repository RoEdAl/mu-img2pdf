###! img2pdf -- Copyright (c) 2022-present, Edmunt Pienkowsky -- license (MIT)###

String::paddingLeft = (paddingValue) -> String(paddingValue + this).slice(-paddingValue.length)
String::endsWith = (suffix) -> this.indexOf(suffix, this.length - suffix.length) != -1

bye = (str = "Bye from #{ScriptPath}") -> throw str

toPdfSaverOpts = (o) -> if Array.isArray(o) then o.join(',') else o

toPdfDate = (d) ->
	dobj = if Array.isArray(d) then new Date(d...) else new Date(d)
	"D:#{dobj.getUTCFullYear().toString().paddingLeft('0000')}#{(dobj.getUTCMonth()+1).toString().paddingLeft('00')}#{dobj.getUTCDate().toString().paddingLeft('00')}#{dobj.getUTCHours().toString().paddingLeft('00')}#{dobj.getUTCMinutes().toString().paddingLeft('00')}00Z"

getPdfId = (pdf, s1, s2) ->
	docId = pdf.newArray()
	docId.push pdf.newString(s1)
	docId.push pdf.newString(s2)
	docId

capitalizeFirstLetter = (s) -> s.charAt(0).toUpperCase() + s.slice(1)

getPdfInfo = (pdf, mtd) ->
	info = {}
	for p in ['author', 'title', 'producer', 'subject', 'creator', 'creationDate', 'modDate']
		continue unless p of mtd
		propName = capitalizeFirstLetter p
		propVal = mtd[p]
		info[propName] = if p.endsWith 'Date' then pdf.newString toPdfDate(propVal) else pdf.newString propVal
	pdf.addObject info

getContents = (pdf, lines...) ->
	buffer = new Buffer()
	buffer.writeLine line for line in lines
	pdf.addStream buffer

pxToPt = (length, dpi) -> 72.0 * length / dpi
round4 = (x) -> Math.round(10000.0 * x)/10000

addImgPage = (pdf, img) ->
	image = new Image(img.path)
	imgWidth = image.getWidth()
	imgHeight = image.getHeight()
	imgXRes = img.resolutionX ? image.getXResolution()
	imgYRes = img.resolutionY ? image.getYResolution()
	pgWidth = round4(pxToPt(imgWidth,imgXRes))
	pgHeight = round4(pxToPt(imgHeight, imgYRes))
	imageObj = pdf.addImage image
	resources = pdf.addObject
		XObject:
			Im0: imageObj
	contents = getContents pdf, "q #{pgWidth} 0 0 #{pgHeight} 0 0 cm /Im0 Do Q"
	pdf.addObject
		Type: 'Page'
		MediaBox: [0,0,pgWidth,pgHeight]
		Contents: contents
		Resources: resources
	
copyPdfPage = (dst, src, pageNumber, dstFromSrc) ->
	srcPage = src.findPage(pageNumber)
	dstPage = dstFromSrc.graftObject(srcPage)
	dst.addObject dstPage
	
copyPdfPages = (pdf, img) ->
	src = new PDFDocument img.path
	dstFromSrc = pdf.newGraftMap()
	n = src.countPages()
	yield copyPdfPage pdf, src, i, dstFromSrc for i in [0..n-1]
	
getPdfPages = (pdf, img) ->
	if img.isPdf ? false
		yield page for page from copyPdfPages pdf, img
	else
		yield addImgPage pdf, img

getImgResolution = (img) ->
	r = {}
	r.resolutionX = r.resolutionY = img.resolution if 'resolution' of img
	r.resolutionX = img.resolutionX if 'resolutionX' of img
	r.resolutionY = img.resolutionY if 'resolutionY' of img
	r

getImgDesc = (img) ->
	switch typeof img
		when 'string' then yield {path: img}
		when 'object'
			switch
				when Array.isArray(img)
					for i in img
						yield innerImg for innerImg from getImgDesc(i)				
				when 'img' of img
					imgRes = getImgResolution(img)
					isPdf = {isPdf: false}
					yield {imgRes..., innerImg..., isPdf...} for innerImg from getImgDesc(img.img)
				when 'pdf' of img
					isPdf = {isPdf: true}
					yield {innerImg..., isPdf...} for innerImg from getImgDesc(img.pdf)
	
bye 'No configuration file' unless scriptArgs.length > 0
cfg = JSON.parse read(scriptArgs[0])
bye 'Empty configuration' unless cfg
bye 'No sources specified in configuration' unless 'src' of cfg
bye 'No output specified in configuration' unless 'output' of cfg

pdf = new PDFDocument()
for img from getImgDesc cfg.src
	pdf.insertPage -1, page for page from getPdfPages pdf, img

trailer = pdf.getTrailer()
if cfg.info?
	trailer.Info = getPdfInfo pdf, cfg.info
else
	delete trailer.Info

if cfg.id? and Array.isArray(cfg.id) and cfg.id.length == 2
	trailer.ID = getPdfId pdf, cfg.id...
else
	delete trailer.ID

pdf.save cfg.output, toPdfSaverOpts(cfg.outputOpts ? ['sanitize','pretty'])
