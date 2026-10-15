# CR 基础示例

创建一个私有 CR 实例、命名空间和 OCI 仓库。

## 1. 概述

此示例代表应用团队最小化的私有镜像仓库基础。

## 2. 用法

通过受保护的变量来源设置 `region`、`registry_name` 和 `namespace_name`，然后执行 `terraform init`、`terraform plan` 与 `terraform apply`。

## 3. 示例

这是 `basic` 场景：私有仓库、命名空间与镜像仓库。

## 4. 版本要求

Terraform `>= 1.5.0`，`volcengine/volcenginecc >= 0.0.70`。

## 5. Provider

`volcenginecc` 使用调用方提供的地域和外部凭据。

## 6. 资源

已发布的 CR 模块创建 Registry、Namespace 和私有 Repository。

## 7. 输入

必填项为 `region`、`registry_name` 和 `namespace_name`。`repository_name` 默认为 `api`，`project` 默认为 `default`。

## 8. 输出

`registry` 和 `repository` 返回不敏感的 CR 元数据。

## 9. 注意事项

示例不创建 IAM 身份、VPC 资源、VKE 集群、镜像拉取 Secret 或保留策略。apply 后请确认第二次 plan 无变更。
