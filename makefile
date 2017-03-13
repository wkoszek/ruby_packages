usage:
	@echo "make p	make a Ruby package"
bootstrap:
	bzr whoami "Wojciech Adam Koszek <wojciech@koszek.com>"
p:
	./ruby_pkg_build.sh
clean:
	rm -rf build-area/ ruby-2* ruby_2* ruby
