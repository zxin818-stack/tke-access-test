# Job-A

这是一个 Kubernetes Job，用于在部署 deployment 之前执行预部署任务。

## 功能说明

- **执行时机**: 使用 Helm Hook `pre-install` 和 `pre-upgrade`，在安装或升级时，在所有 deployment 之前执行
- **执行顺序**: Hook Weight 为 `-5`，确保在 job-b 之前执行
- **任务内容**: 
  - 检查环境
  - 初始化资源
  - 验证配置

## 配置说明

### values.yaml 配置项

```yaml
job:
  name: job-a
  hookWeight: "-5"                    # Hook 权重，越小越先执行
  hookDeletePolicy: "before-hook-creation,hook-succeeded"  # Hook 删除策略
  ttlSecondsAfterFinished: 100        # Job 完成后保留时间
  backoffLimit: 3                     # 失败重试次数
  parallelism: 1                      # 并行度
  completions: 1                      # 完成次数

image:
  repository: busybox
  tag: "1.36"
  pullPolicy: IfNotPresent

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

## 使用方法

### 1. 安装整个 Chart（包含 job-a）

```bash
helm install my-release .
```

### 2. 单独启用/禁用 job-a

在主 values.yaml 中：

```yaml
job-a:
  enabled: true  # 设置为 false 可禁用
```

### 3. 查看 Job 执行日志

```bash
# 查看 Job 状态
kubectl get jobs

# 查看 Job 的 Pod
kubectl get pods -l app.kubernetes.io/name=job-a

# 查看 Job 日志
kubectl logs -l app.kubernetes.io/name=job-a
```

## Hook 说明

### Helm Hook 注解

```yaml
annotations:
  "helm.sh/hook": pre-install,pre-upgrade
  "helm.sh/hook-weight": "-5"
  "helm.sh/hook-delete-policy": "before-hook-creation,hook-succeeded"
```

- **helm.sh/hook**: 指定 Hook 类型，`pre-install` 和 `pre-upgrade` 表示在安装和升级前执行
- **helm.sh/hook-weight**: Hook 权重，数字越小越先执行，job-a 为 `-5`，job-b 为 `-3`
- **helm.sh/hook-delete-policy**: Hook 删除策略
  - `before-hook-creation`: 在新 Hook 创建前删除旧的
  - `hook-succeeded`: Hook 成功后删除

## 执行顺序

在 Helm 安装/升级时的执行顺序：

1. **job-a** (weight: -5) - 最先执行
2. **job-b** (weight: -3) - 第二执行
3. **demo-a deployment** - 普通资源，在所有 Hook 完成后部署
4. **demo-b deployment** - 普通资源，在所有 Hook 完成后部署

## 故障排查

### Job 失败

```bash
# 查看 Job 详情
kubectl describe job <job-name>

# 查看 Pod 日志
kubectl logs <pod-name>

# 查看 Pod 事件
kubectl describe pod <pod-name>
```

### Job 未执行

检查：
1. Chart 中是否正确配置了依赖
2. values.yaml 中 `job-a.enabled` 是否为 `true`
3. Helm 安装命令是否正确

## 自定义任务

修改 `templates/job.yaml` 中的 `command` 部分来自定义任务内容：

```yaml
command:
  - sh
  - -c
  - |
    echo "Your custom tasks here"
    # 添加你的自定义命令
```
