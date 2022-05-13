#WIP Step 1

`apt-get install -y trivy`{{exec}}

`trivy --version`{{exec}}

`trivy image --help`{{exec}}

`trivy image nginx:1.21.6-alpine`{{exec}}

`trivy -q image --format template --template '{{- $pkg := list }}{{ range . }}{{ .Target }} ** {{ range .Vulnerabilities }}{{- $pkg = append $pkg .PkgName }}{{ end }}{{ end }}{{ range uniq $pkg }}{{ .}} {{ end }}'  nginx:1.21.6-alpine`{{exec}}


trivy -q image --format template --template '{{ range . }}{{ regexFind "\(([a-z]+)" .Target }}{{ end }}'  nginx:1.21.6-alpine
