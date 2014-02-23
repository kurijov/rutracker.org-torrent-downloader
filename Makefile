test:
	NODE_ENV=test coffee install/drop
	NODE_ENV=test coffee install/db
	NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter list \
		--compilers coffee:coffee-script \
		--recursive ./tests \
		--require ./tests/fixture.coffee