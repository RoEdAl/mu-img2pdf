#
# webpack.config
#
webpack = require 'webpack'
node_dir = __dirname + '/node_modules'

# minimalEnv =
	# arrowFunction: false
	# bigIntLiteral: false
	# const: false
	# destructuring: false
	# dynamicImport: false
	# forOf: false
	# module: false
	# optionalChaining: false
	# templateLiteral: false
	
coffeeLoader = 
	test: /\.coffee$/
	loader: 'coffee-loader'
	options:
		bare: false,
		transpile:
			presets: ['@babel/env']
			sourceType: 'script'

config =
	context: __dirname
	entry: './img2pdf.coffee'
	target: 'es5'
	devtool: false
	node: false
	output:
		path: __dirname + '/public'
		filename: 'img2pdf.js'
		chunkFormat: 'commonjs' # must be specified when target == es5
	optimization:
		minimize: false
	module:
		rules: [coffeeLoader]

module.exports = (env) -> 
	config.mode = if env.production then 'production' else 'development'
	config.optimization.minimize = env.production
	config.stats = if env.production then 'errors-only' else 'minimal'
	config
