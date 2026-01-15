{{/*
Expand the name of the chart.
*/}}
{{- define "adp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "adp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "adp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "adp.labels" -}}
helm.sh/chart: {{ include "adp.chart" . }}
{{ include "adp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "adp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "adp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
判断是否需要 initContainer
直接检测节点 label 中是否包含 "tke.cloud.tencent"
*/}}
{{- define "adp.needInitContainer" -}}
{{- $needInit := false -}}
{{- $nodes := lookup "v1" "Node" "" "" -}}
{{- if $nodes -}}
  {{- range $nodes.items -}}
    {{- range $key, $value := .metadata.labels -}}
      {{- if contains "tke.cloud.tencent" $key -}}
        {{- $needInit = true -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if $needInit -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}