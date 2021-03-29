build:
	rm -rf public && rm -rf docs && hugo && mv public docs
deploy: build
	git add ./ && git commit -m "deploy" && git push origin master
