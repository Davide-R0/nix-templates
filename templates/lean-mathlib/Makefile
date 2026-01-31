.PHONY: docs serve

# Compila la documentazione
docs:
	cd docbuild && lake build Ananke:docs

# Avvia il server (dipende da 'docs' così compila prima se serve)
serve: docs
	python3 -m http.server -d docbuild/.lake/build/doc 8000

# Create dependency graph
graph:
	lake exe graph to imports.dot
	dot -Tpng imports.dot -o imports.png
