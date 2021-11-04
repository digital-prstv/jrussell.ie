set shell := ["sh", "-c"]

_default:
    @just --list

build-site:
    docker run -u "$(id -u):$(id -g)" -v $PWD:/app --workdir /app balthek/zola:0.14.0 build

publish-site:
    aws s3 cp public s3://www.jrussell.ie --recursive
