update/theme:
	git submodule update --remote --merge

build:
	hugo --minify

build/preview:
	hugo --minify --environment preview

serve:
	hugo serve -D

serve/preview:
	hugo serve -D --environment preview
