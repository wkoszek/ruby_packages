RUBY_VERSION=2.4.0

usage:
	@echo "make p	make a Ruby package"
bootstrap:
	bzr whoami "Wojciech Adam Koszek <wojciech@koszek.com>"
p:
	./ruby_pkg_build.sh $(RUBY_VERSION)
clean:
	rm -rf build-area/ ruby-2* ruby_2* ruby
