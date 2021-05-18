{{/*
Expand the name of the chart.
*/}}
{{- define "benisbot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "benisbot.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "benisbot.postgresHost" -}}
{{- printf "%s-postgresql" (include "benisbot.fullname" .) }}
{{- end }}

{{- define "benisbot.postgresUrl" -}}
{{- printf "postgresql://%s:%s@%s:%d/%s?schema=public" .Values.postgresql.postgresqlUsername .Values.postgresql.postgresqlPassword (include "benisbot.postgresHost" .) 5432 .Values.postgresql.postgresqlUsername }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "benisbot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "benisbot.labels" -}}
helm.sh/chart: {{ include "benisbot.chart" . }}
{{ include "benisbot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "benisbot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "benisbot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "benisbot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "benisbot.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
