all:
	@./build.sh

clean:
	@rm -f output/document.*
	@echo "Cleaned output directory"
