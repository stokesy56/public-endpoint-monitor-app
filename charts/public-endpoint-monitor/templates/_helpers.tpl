{{- define "pem.fullname" -}}
{{- printf "%s-%s" .Release.Name "pem" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pem.labels" -}}
app.kubernetes.io/name: pem
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "pem.selectorLabels" -}}
app.kubernetes.io/name: pem
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "public-endpoint-monitor.fullname" -}}
{{ include "pem.fullname" . }}
{{- end -}}

{{- define "public-endpoint-monitor.labels" -}}
{{ include "pem.labels" . }}
{{- end -}}

{{- define "public-endpoint-monitor.selectorLabels" -}}
{{ include "pem.selectorLabels" . }}
{{- end -}}