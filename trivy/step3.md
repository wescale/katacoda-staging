`trivy image --help`{{exec}}

`trivy image nginx:1.21.6-alpine`{{exec}}

`trivy -q image --format template --template '{{- $pkg := list }}{{- $os := ""}}{{ range . }}{{- $os = regexFind "\\(([a-z]+)" .Target }}{{ range .Vulnerabilities }}{{- $pkg = append $pkg .PkgName }}{{ end }}{{ end }}{{ trimPrefix "(" $os }} || {{ range uniq $pkg }}{{ . }} {{ end }}'  nginx:1.21.6-alpine`{{exec}}


trivy -q image --format template --template '{{- $os := ""}}{{ range . }}{{- $os = regexFind "\\(([a-z]+)" .Target }}{{ end }}{{ trimPrefix "(" $os }} '  rg.fr-par.scw.cloud/katacoda/alpine:latest

trivy -q image --format template --template '{{- $pkg := list }}{{- $os := ""}}{{- $image := ""}}{{ range . }}{{- $os = regexFind "\\(([a-z]+)" .Target }}{{ range .Vulnerabilities }}{{- $pkg = append $pkg .PkgName }}{{ end }}{{ end }}{{ trimPrefix "(" $os }} ** {{ range uniq $pkg }}{{ . }} {{ end }}' rg.fr-par.scw.cloud/katacoda/alpine:latest
