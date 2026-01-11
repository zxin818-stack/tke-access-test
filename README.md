# ADP Helm Chart

这是一个简单的ADP应用Helm chart，用于在Kubernetes集群中部署ADP应用。

## 安装

### 添加Helm仓库
```bash
helm repo add tkestack https://raw.githubusercontent.com/tkestack/charts/master/repo/stable
```

### 安装chart
```bash
helm install my-adp tkestack/adp
```

## 配置

chart的主要配置参数在`values.yaml`文件中定义：

- `replicaCount`: Pod副本数量（默认：1）
- `image.repository`: 容器镜像仓库（默认：nginx）
- `image.tag`: 容器镜像标签（默认：latest）
- `service.type`: Service类型（默认：ClusterIP）
- `service.port`: Service端口（默认：80）

## 自定义安装

您可以通过values文件或命令行参数自定义安装：

```bash
helm install my-adp tkestack/adp --set replicaCount=3 --set image.repository=myregistry/adp
```

或使用自定义values文件：

```bash
helm install my-adp tkestack/adp -f my-values.yaml
```

## 升级

```bash
helm upgrade my-adp tkestack/adp
```

## 卸载

```bash
helm uninstall my-adp
```