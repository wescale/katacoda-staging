#!/bin/bash

docker build -t . trivy-tested-image:latest

export input=$(trivy -q image --format template --template '{{- $pkg := list }}{{- $os := ""}}{{- $image := ""}}{{ range . }}{{- $os = regexFind "\\(([a-z]+)" .Target }}{{ range .Vulnerabilities }}{{- $pkg = append $pkg .PkgName }}{{ end }}{{ end }}{{ trimPrefix "(" $os }} -- {{ range uniq $pkg }}{{ . }} {{ end }}' trivy-tested-image:latest)

python fix.py $input

mv Dockerfile Dockerfile.original

mv Dockerfile.patch Dockerfile

docker build -t . trivy-tested-image:patch

trivy -q image trivy-tested-image:patch


#export input=$(trivy -q image --format template --template '{{- $pkg := list }}{{- $os := ""}}{{- $image := ""}}{{ range . }}{{- $os = regexFind "\\(([a-z]+)" .Target }}{{ range .Vulnerabilities }}{{- $pkg = append $pkg .PkgName }}{{ end }}{{ end }}{{ trimPrefix "(" $os }} -- {{ range uniq $pkg }}{{ . }} {{ end }}' nginx:1.21.6)

#python fix.py $input
