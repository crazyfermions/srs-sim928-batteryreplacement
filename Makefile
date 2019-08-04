.DEFAULT_GOAL := html

md:
	pandoc doc.rst -o doc.md

html:
	make md
	pandoc doc.md --css=style.css -o doc.html

clean:
	@echo "Removing docs"
	rm doc.md
	rm doc.html
	
