set shell := ["sh", "-c"]

_default:
    @just --list

build-site:
    zola build

publish-site:
    aws s3 cp public s3://www.jrussell.ie --recursive
