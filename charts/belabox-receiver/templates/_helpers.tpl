{{/* Return the chart name */}}
{{- define "belabox-receiver.name" -}}
belabox-receiver
{{- end }}

{{/* Generate a full name: chartname-release */}}
{{- define "belabox-receiver.fullname" -}}
{{ include "belabox-receiver.name" . }}-{{ .Release.Name }}
{{- end }}
