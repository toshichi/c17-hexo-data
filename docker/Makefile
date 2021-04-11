.PHONY: clean gen push

all: gen

gen: data-pre
	hexo g

# auto push to github
# token should be set by env var, see: https://github.com/hexojs/hexo-deployer-git
push: data-pre
	hexo deploy

data-pre:
# clear unused init files
	rm -rf source
# copy source files to overwrite init files
	cp -rf ../data/* .
# move image files and process image paths in md files
	chmod +rx ./mdprocess.sh
	./mdprocess.sh
# get themes
	git clone --depth 1 https://github.com/toshichi/hexo-theme-coder17.git themes/coder17

clean:
	hexo clean