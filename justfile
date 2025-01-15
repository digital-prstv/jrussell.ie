set shell := ["sh", "-c"]

_default:
    @just --list

build-site:
    git submodule sync
    git submodule update --init --recursive
    zola build

publish-site:
    aws s3 cp public s3://www.jrussell.ie --recursive

serve:
    zola serve --drafts

build-serve: build-site serve