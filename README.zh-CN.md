# terraform-volcenginecc-cr

用于管理火山引擎容器镜像仓库（CR）实例、命名空间、私有 OCI 仓库、机器人账号、VPC Endpoint 和显式公网 CIDR 白名单的 Terraform 模块。

## 1. 概述

模块拥有输入 map 中声明的 CR 资源。调用方负责 Provider 凭据、地域、IAM 用户和角色、VKE 集群、VPC、子网、镜像构建及推送操作，以及 Kubernetes 镜像拉取 Secret。

当前 Provider Schema 中，Registry 的名称、项目、类型和标签，Namespace 的全部身份字段，Repository 的身份字段，机器人账号的 Registry 和用户名，VPC Endpoint 的 Registry，以及公网白名单条目均为 create-only。请保持 map key 稳定，修改 key 会改变 Terraform 资源地址。

## 2. 用法

### 2.1 基础用法

```hcl
module "cr" {
  source  = "terraform-volcenginecc-modules/cr/volcenginecc"
  version = "~> 1.0"

  region     = "cn-beijing"
  account_id = 2000000000

  registries = {
    app = {
      name = "example-cr"
    }
  }

  namespaces = {
    team = {
      registry_key = "app"
      name         = "team"
    }
  }

  repositories = {
    api = {
      namespace_key = "team"
      name          = "api"
    }
  }
}
```

## 3. 示例

- `basic` 描述私有仓库、命名空间与镜像仓库。
- `complete` 描述 CI 推送权限、VKE 私网拉取 Endpoint、可选公网 CIDR 白名单及独立的只拉取凭据。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.0` |
| VolcengineCC Provider | `>= 0.0.70` |

## 5. Provider

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 用途 |
|---|---|
| `volcenginecc_cr_registry` | CR 实例 |
| `volcenginecc_cr_name_space` | 实例命名空间 |
| `volcenginecc_cr_repository` | 私有或公开 OCI 仓库 |
| `volcenginecc_cr_robot_account` | 范围受限的 CI/CD 或 VKE 机器人凭据 |
| `volcenginecc_cr_vpc_endpoint` | 私网镜像拉取 Endpoint |
| `volcenginecc_cr_endpoint_acl_policy` | 显式公网 CIDR 白名单 |

## 7. 输入

| 名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `region` | `string` | 必填 | 用于生成系统域名仓库 URL 与仓库 TRN 的 CR 地域 ID，必须与 Provider 地域一致。 |
| `account_id` | `number` | 必填 | CR 实例所属账号 ID，用于生成仓库 TRN。 |
| `registries` | `map(object)` | 必填 | 稳定 key 的 CR 实例；默认不启用公网 Endpoint。 |
| `namespaces` | `map(object)` | `{}` | 引用模块管理 Registry 的稳定 key 命名空间。 |
| `repositories` | `map(object)` | `{}` | 引用模块管理 Namespace 的稳定 key 仓库；默认 `Private`。 |
| `include_update_timestamps` | `bool` | `false` | 是否在输出中包含 Provider 回传的仓库与机器人账号更新时间。 |
| `robot_accounts` | `map(object)` | `{}` | 配置 CreateRepository、PullRepository 和/或 PushRepository 权限的受限机器人账号。 |
| `vpc_endpoints` | `map(object)` | `{}` | 引用调用方 VPC 与子网的私网 Endpoint。 |
| `public_endpoint_acl_policies` | `map(object)` | `{}` | 显式公网 Endpoint CIDR；拒绝 `0.0.0.0/0`。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `registries` | 按输入 key 返回实例 ID、名称、状态和公网 Endpoint 状态。 |
| `namespaces` | 按输入 key 返回命名空间元数据。 |
| `repositories` | 按输入 key 返回镜像仓库元数据、不含 tag 的系统域名 URL 和 IAM 仓库 TRN。 |
| `robot_accounts` | 按输入 key 返回不含密码的机器人账号元数据。 |
| `vpc_endpoints` | 按输入 key 返回私网 Endpoint 详情及云端回传 VPC 地址。 |

## 9. 注意事项

- Provider Schema 未提供 CR 镜像保留策略资源、镜像扫描开关、CR IAM 用户/角色授权资源或 `force_delete` 设置。Provider 不回传仓库 URL 或 TRN，因此模块按官方标准版系统域名规则生成 `repository_url`，按官方 CR IAM 格式生成 `repository_trn`。
- 机器人账号是当前 Provider 可管理的推拉身份。手工提供或随机生成的密码不会被输出，但当前 Provider 未将其标记为敏感且可能保存在 State 中；不要写入源码，须使用加密远端 State，并通过受控密钥流程轮换。
- VKE 集成只创建 CR VPC Endpoint。请在模块外使用返回的镜像地址和机器人凭据配置 VKE 工作负载的镜像拉取 Secret。
- 仅在必要时启用公网 Endpoint，并使用最小范围 CIDR。默认安全姿态是私有仓库、私网 Endpoint 和 VKE 只拉取账号。
- 声明已有资源前请按 Provider 标识导入：Registry 为 `name`，Namespace 为 `registry|name`，Repository 为 `registry|namespace|name`，机器人账号为 `registry|username`。
- apply 后应执行第二次 `terraform plan`，只有返回 `No changes` 时才可认为配置已收敛。
- 模块不管理调用方的 ECS、子网、安全组和 VPC。若在同一次 Terraform 操作中销毁这些资源，底层 ENI 可能在 ECS 删除后异步释放；子网删除返回占用错误时，应等待 ENI 释放后重新执行 destroy，不要在本模块中加入固定等待时间。
- complete 将机器人账号权限收窄至配置的命名空间：CI 仅推拉，VKE 仅拉取。投入生产前请按目标 CR API 验证资源标识格式。
- `repository_url` 不含 tag，使用标准版系统域名：`<registry>-<region>.cr.volces.com/<namespace>/<repository>`；它不是自定义域名或控制台当前设置的默认域名。`repository_trn` 使用 CR IAM 格式：`trn:cr:<region>:<account_id>:repository/<registry>/<namespace>/<repository>`。
