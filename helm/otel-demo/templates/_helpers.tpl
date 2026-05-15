{{/*
Full image name
*/}}
{{- define "otel-demo.image" -}}
{{- if .service.useFullImage -}}
{{ .service.image }}
{{- else -}}
{{ .root.Values.registry }}/{{ .service.image }}:{{ .root.Values.imageTag }}
{{- end -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "otel-demo.labels" -}}
app.kubernetes.io/part-of: otel-demo
app.kubernetes.io/managed-by: Helm
{{- end }}

{{/*
Service labels
*/}}
{{- define "otel-demo.serviceLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/component: {{ .name }}
{{ include "otel-demo.labels" .root }}
{{- end }}
