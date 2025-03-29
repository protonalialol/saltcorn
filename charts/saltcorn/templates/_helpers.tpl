{{/*
Expand the name of the chart.
*/}}
{{- define "saltcorn.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "saltcorn.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "saltcorn.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "saltcorn.labels" -}}
helm.sh/chart: {{ include "saltcorn.chart" . }}
{{ include "saltcorn.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "saltcorn.selectorLabels" -}}
app.kubernetes.io/name: {{ include "saltcorn.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "saltcorn.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "saltcorn.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create persistence env vars for saltcorn
*/}}
{{- define "saltcorn.envPersistence" -}}
{{- if eq .Values.persistence.type "postgresql" -}}
- name: PGUSER
  value: "{{ .Values.persistence.postgresql.pgUser }}"
- name: PGPASSWORD
  value: "{{ .Values.persistence.postgresql.pgPassword }}"
- name: PGHOST
  value: "{{ .Values.persistence.postgresql.pgHost }}"
- name: PGPORT
  value: "{{ .Values.persistence.postgresql.pgPort }}"
- name: PGDATABASE
  value: "{{ .Values.persistence.postgresql.pgDatabase }}"
{{- else if eq .Values.persistence.type "pvc" -}}
- name: SQLITE_FILEPATH
  value: /mnt/db/sqlite.db
{{- end }}
{{- end }}

{{/*
Create volume entries for type "pvc"
*/}}
{{- define "saltcorn.volumePvc" -}}
{{- if eq .Values.persistence.type "pvc" -}}
- name: {{ .Values.persistence.pvc.existingClaim | default .Release.Name }}
  persistentVolumeClaim:
    claimName: {{ .Values.persistence.pvc.existingClaim | default .Release.Name }}
{{- end }}
{{- end }}

{{/*
Create volumeClaim entries for type "pvc"
*/}}
{{- define "saltcorn.volumeClaimPvc" -}}
{{- if eq .Values.persistence.type "pvc" -}}
- name: {{ .Values.persistence.pvc.existingClaim | default .Release.Name }}
  mountPath: /mnt/db
{{- end }}
{{- end }}

{{/*
Create reset-schema args
*/}}
{{- define "saltcorn.argsReset" -}}
- "reset-schema"
- "-f"
{{- end }}

{{/*
Create server args
*/}}
{{- define "saltcorn.argsServer" -}}
- "serve"
{{- if .Values.server.debug }}
- "-v"
{{- end }}
{{- end }}
