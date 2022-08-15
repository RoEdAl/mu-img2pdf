###! mu-img2pdf -- Copyright (c) 2022-present, Edmunt Pienkowsky -- license (MIT): https://github.com/RoEdAl/mu-img2pdf ###

String::paddingLeft = (paddingValue) -> String(paddingValue + this).slice(-paddingValue.length)
String::endsWith = (suffix) -> this.indexOf(suffix, this.length - suffix.length) != -1

bye = (str = "Bye from #{ScriptPath}") -> throw str

toPdfSaverOpts = (o) -> if Array.isArray(o) then o.join(',') else o

pdfTransform = (x, y, m) -> [m[0]*x+m[2]*y+m[4], m[1]*x+m[3]*y+m[5]]
pdfTransformRect = (a, m) ->
	t1 = pdfTransform a[0], a[2], m
	t2 = pdfTransform a[1], a[3], m
	[t1[0], t2[0], t1[1], t2[1]]

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

getImgPage = (pdf, img) ->
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
	srcPage = src.findPage pageNumber
	dstPage = dstFromSrc.graftObject srcPage
	dst.addObject dstPage
	
copyPdfPages = (dst, img) ->
	src = new PDFDocument img.path
	dstFromSrc = dst.newGraftMap()
	n = src.countPages()
	yield copyPdfPage dst, src, i, dstFromSrc for i in [0..n-1]

copyDocPages = (pdf, tmpDocPath, doc) ->
	unless tmpDocPath?
		print "Unable to copy document #{doc.path}, temporary document path is undefined"
		return
	src = new Document doc.path
	n = src.countPages()
	gc()
	docWriter = new DocumentWriter tmpDocPath
	try
		for p in [0..n-1]
			srcPage = src.loadPage p
			transform = Scale(doc.scaleX ? 1, doc.scaleY ? 1)
			mediaBox = srcPage.bound()
			mediaBox = pdfTransformRect mediaBox, transform
			dev = docWriter.beginPage mediaBox
			try
				srcPage.run dev, transform, true
			finally
				dev.close()
				docWriter.endPage()
	finally
		docWriter.close()
	yield page for page from copyPdfPages pdf, {path: tmpDocPath}
	
getPdfPages = (pdf, tmpDocPath, img) ->
	switch img.type ? 'img'
		when 'pdf' then yield page for page from copyPdfPages pdf, img
		when 'img' then yield getImgPage pdf, img
		when 'doc' then yield page for page from copyDocPages pdf, tmpDocPath, img

getImgResolution = (img) ->
	r = {}
	r.resolutionX = r.resolutionY = img.resolution if 'resolution' of img
	r.resolutionX = img.resolutionX if 'resolutionX' of img
	r.resolutionY = img.resolutionY if 'resolutionY' of img
	r

getDocScale = (doc) ->
	r = {}
	r.scaleX = r.scaleY = doc.scale if 'scale' of doc
	r.scaleX = doc.scaleX if 'scaleX' of doc
	r.scaleY = doc.scaleY if 'scaleY' of doc
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
					docType = type: 'img'
					yield {imgRes..., innerImg..., docType...} for innerImg from getImgDesc(img.img)
				when 'pdf' of img
					docType = type: 'pdf'
					yield {innerImg..., docType...} for innerImg from getImgDesc(img.pdf)
				when 'doc' of img
					docScale = getDocScale(img)
					docType = type: 'doc'
					yield {docScale..., innerImg..., docType...} for innerImg from getImgDesc(img.doc)
	
bye 'No configuration file' unless scriptArgs.length > 0
cfg = JSON.parse read(scriptArgs[0])
bye 'Empty configuration' unless cfg
bye 'No sources specified in configuration' unless 'src' of cfg
bye 'No output specified in configuration' unless 'output' of cfg

pdf = new PDFDocument()
for img from getImgDesc cfg.src
	pdf.insertPage -1, page for page from getPdfPages pdf, cfg.tmpDocPath, img

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
