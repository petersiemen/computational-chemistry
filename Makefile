export PYTHONUNBUFFERED := 1
.DEFAULT_GOAL := dev.build

.venv:
	virtualenv -p /usr/bin/python3.7 .venv

.PHONY: dev.build
build: .venv
	.venv/bin/python -m pip install -r requirements.txt


.PHONY: dev.build
dev.build: .venv
	.venv/bin/python -m pip install -r requirements-dev.txt

.PHONY: mypy
mypy:
	.venv/bin/mypy \
		--ignore-missing-imports \
		--config-file "./settings.ini" \
		noword2vec

.PHONY: format
format:
	.venv/bin/autopep8 \
		--max-line-length 105 \
		--in-place \
		--recursive \
		--experimental \
		src

.PHONY: test
test: format
	.venv/bin/pytest tests

.PHONY: ci.test
ci.test: _validate_format
	make test

.PHONY: dist
dist: _sdist.clean _bdist_wheel.clean _dist


.PHONY: _bdist_wheel.clean
_bdist_wheel.clean:
	ls ./dist/*.whl \
		| grep now-es-index- \
		| while read f; do echo "./dist/$$f"; rm -f "./dist/$$f"; done

.PHONY: _sdist.clean
_sdist.clean:
	ls ./dist/*.tar.gz \
		| grep now-es-index- \
		| while read f; do echo "./dist/$$f"; rm -f "./dist/$$f"; done

.PHONY: _dist
_dist:
	.venv/bin/python setup.py sdist bdist_wheel --dist-dir ./dist/
	rm -rf ./build

.PHONY: _validate_format
_validate_format:
	.venv/bin/autopep8 \
		--max-line-length 105 \
		--diff \
		--recursive \
		--experimental \
		--exit-code \
		src

.PHONY: data
data:
	mkdir -p \
		./data/dev \
		./data/test

# after refactorings, this might be required
.PHONY: pyclean
pyclean:
	find . -name '__pycache__' | xargs rm -rf
	find . -name '*.pyc' | xargs rm -rf
	find . -name '*.pyo' | xargs rm -rf
	rm -rf ./data/test

# use in case of trouble
.PHONY: clean
clean: pyclean
	rm -rf .mypy_cache .pytest_cache dist .venv *egg-info unittests.cfg


