test:
	./node_modules/.bin/mocha \
		--reporter list \
		--compilers coffee:coffee-script \
		--recursive ./tests \
		--require should