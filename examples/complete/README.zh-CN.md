# CR 完整示例

创建私有应用仓库、CI 推送机器人账号、VKE 只拉取机器人账号，以及调用方 VKE VPC 内的 CR 私网 Endpoint。

## 1. 概述

此示例建模 CI/CD 镜像推送和 VKE 私有镜像拉取，同时保持仓库私有。

## 2. 用法

通过受保护的变量来源提供 CR 名称和调用方 VKE VPC/子网值，然后执行 `terraform init`、`terraform plan` 与 `terraform apply`。

## 3. 示例

这是 `complete` 场景：私有仓库、CI 推送权限、VKE 拉取权限和私网 Endpoint 访问。

## 4. 版本要求

Terraform `>= 1.5.0`，`volcengine/volcenginecc >= 0.0.70`。

## 5. Provider

`volcenginecc` 使用调用方提供的地域和外部凭据。

## 6. 资源

已发布的 CR 模块创建 CR 层级、两个命名空间范围的机器人账号和一个 CR VPC Endpoint。仅在显式启用公网 Endpoint 后才创建公网 CIDR 白名单。

## 7. 输入

Registry 和机器人账号名称，以及 VKE VPC/子网/账号值为必填项。`account_id` 必须同时是 CR 实例所属账号（用于生成仓库 TRN）和本示例中 VKE VPC 所属账号。公网 Endpoint 默认关闭；启用时仅设置非全网开放的 CI CIDR。

## 8. 输出

`repositories`、`repository_urls`、`repository_trns`、`robot_accounts` 和 `vke_private_endpoint` 返回不敏感元数据。仓库 URL 为不含 tag 的系统域名地址；不会输出机器人账号密码。

## 9. 注意事项

VKE 集群及其镜像拉取 Secret 仍由调用方管理。两个机器人账号均以 `var.namespace_name` 作为权限资源：CI 仅拉取和推送，VKE 仅拉取。Provider 不支持 CR 保留策略或 CR IAM 用户/角色授权。apply 后请确认第二次 plan 无变更，再在已授权的临时环境验证实际 CI 推送、VKE 拉取和 destroy 清理。
