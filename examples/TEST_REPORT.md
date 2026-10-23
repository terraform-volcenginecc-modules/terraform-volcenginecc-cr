# CR 模块真实云验证报告

## 1. 结论

本次使用线上 `volcengine/volcenginecc` Provider `v0.0.71` 和 Terraform `v1.5.7` 完成了 basic 与 complete 的完整生命周期验证。

basic 和 complete 在 apply 后第二次 plan 均返回 `No changes`。complete 的 CI 推拉与 VKE 只拉取机器人账号均已成功创建。所有本次创建的资源已销毁；Registry、Namespace、Repository 与 VPC Endpoint 回查均返回 `Data Source Not Found`，机器人账号因父 Registry 已删除返回 `NotFound.Registry`。

后续版本新增的 `repository_url` 和 `repository_trn` 已在独立 basic 临时环境完成真实 apply、值断言和二次 plan 验证。该验证只覆盖 URL/TRN 输出；complete 中收窄至命名空间的机器人权限需要单独复测。

## 2. 验证环境

| 项目 | 值 |
|---|---|
| 执行日期 | 2026-10-14 |
| Terraform | `v1.5.7` |
| Provider | `volcengine/volcenginecc v0.0.71`，线上 Registry |
| 地域 | `cn-beijing` |
| Provider 凭据 | 通过进程环境变量传入用户提供的原始 AccessKeyID、SecretAccessKey 和空 SessionToken；未写入文件、日志或 State 输出 |
| 测试隔离 | 临时验证目录 `tests/real-cloud-run/`，未修改发布示例的远程模块 source |
| URL/TRN 输出复测 | 2026-10-23；临时本地调用方，Provider `v0.0.71`，Terraform `v1.5.7`；未修改发布示例的远程模块 source |

## 3. 验证对象

| 场景 | 临时资源 |
|---|---|
| basic | Registry `ccapitestcrbasic1014`、Namespace `basic`、Repository `api` |
| complete | Registry `ccapitestcrfull1014`、Namespace `application`、Repository `api` / `worker`、CR VPC Endpoint |
| complete 网络 | VPC `vpc-13f8k4dwdsydc3n6nu5r0ygbh`、Subnet `subnet-13frgq5lwgg743n6nu4fu0ve9`、Account `2107436677` |

## 4. 已执行验证

| 验证项 | 结果 | 证据与结论 |
|---|---|---|
| basic：plan | 通过 | 计划为 `3 to add`：Registry、Namespace、私有 Repository。 |
| basic：apply | 通过 | 创建 `3 added`；Registry 状态 `Running`，公网 Endpoint 状态 `Disabled`。 |
| basic：仓库可见性 | 通过 | Repository 输出 `access_level = Private`，ID 为 `ccapitestcrbasic1014\|basic\|api`。 |
| basic：Repository 输出 | 部分通过 | Provider 返回可用的 ID、Registry、Namespace、Name、Private 可见性及创建/更新时间；该 Schema 不提供 repository URL 或 ARN。 |
| basic：二次 plan | 通过 | 输出 `No changes. Your infrastructure matches the configuration.` |
| basic：destroy 与回查 | 通过 | destroy 为 `3 destroyed`；Registry、Namespace、Repository 数据源均返回 `Data Source Not Found`。 |
| basic：派生 Repository URL/TRN | 通过 | apply 后断言 `repository_url = crout1023172626-cn-beijing.cr.volces.com/verify/api`，`repository_trn = trn:cr:cn-beijing:2107436677:repository/crout1023172626/verify/api`；均与 Registry、Region、Account、Namespace、Repository 输入一致。 |
| basic：派生输出二次 plan | 通过 | 新输出 apply 后执行 `plan -detailed-exitcode` 返回 `No changes. Your infrastructure matches the configuration.`。 |
| basic：派生输出 destroy | 通过 | 临时 Registry、Namespace、Repository 均已 destroy，输出为 `3 destroyed`。 |
| complete：plan | 通过 | 计划为 `7 to add`：Registry、Namespace、2 Repository、2 RobotAccount、VPC Endpoint。 |
| complete：Registry/Namespace/Repository | 通过 | Registry、Namespace、2 个 `Private` Repository 创建成功。 |
| complete：VPC Endpoint | 通过 | 指定 VPC、Subnet、Account 的 Endpoint 创建成功，后续 destroy 成功。 |
| complete：CI 读写角色 | 通过 | 使用 CR OpenAPI 明确支持的 `resource = "*"`；账号仅包含 `PullRepository` 和 `PushRepository` 两个动作，创建成功。 |
| complete：VKE 只读角色 | 通过 | 使用 `resource = "*"`；账号仅包含 `PullRepository`，创建成功。 |
| complete：二次 plan | 通过 | apply 后输出 `No changes. Your infrastructure matches the configuration.` |
| complete：destroy 与回查 | 通过 | destroy 为 `7 destroyed`；Registry、Namespace、2 Repository、VPC Endpoint 数据源均返回 `Data Source Not Found`；机器人账号因父 Registry 已删除返回 `NotFound.Registry`。 |
| 生命周期保留规则 | Provider 受阻 | `v0.0.71` 没有 CR 镜像生命周期/保留策略资源，无法配置或验证保留规则。 |
| 镜像扫描开关 | Provider 受阻 | `v0.0.71` CR Registry/Repository Schema 未暴露扫描配置。 |
| 权限策略 | Provider 受阻 | Provider 无 CR IAM 用户/角色策略资源；RobotAccount 是当前可管理的推拉身份机制，已按 OpenAPI 支持的 `resource = "*"` 验证。 |
| 非空仓库 force_delete | Provider 受阻 | Repository/Registry Schema 没有 `force_delete`；未推送测试镜像，不能把空仓库 destroy 误报为非空仓库强制删除验证。 |

## 5. 已执行命令与关键输出

```text
terraform version
Terraform v1.5.7

terraform -chdir=tests/real-cloud-run/basic plan -out=basic.tfplan
Plan: 3 to add, 0 to change, 0 to destroy.

terraform -chdir=tests/real-cloud-run/basic apply basic.tfplan
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
Registry: Running; public endpoint: Disabled
Repository: ccapitestcrbasic1014|basic|api; access_level: Private

terraform -chdir=tests/real-cloud-run/basic plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

terraform -chdir=tests/real-cloud-run/basic destroy -auto-approve
Destroy complete! Resources: 3 destroyed.

terraform -chdir=tests/real-cloud-run/complete plan -out=complete.tfplan
Plan: 7 to add, 0 to change, 0 to destroy.

terraform -chdir=tests/real-cloud-run/complete apply complete.tfplan
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
CI robot: PullRepository + PushRepository; VKE robot: PullRepository.

terraform -chdir=tests/real-cloud-run/complete plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

terraform -chdir=tests/real-cloud-run/complete destroy -auto-approve
Destroy complete! Resources: 7 destroyed.

terraform -chdir=tests/real-cloud-run/absence plan
Registry, Namespace, Repository and VPC Endpoint: Data Source Not Found
Robot accounts: NotFound.Registry after parent Registry deletion

terraform -chdir=/tmp/cr-output-validation apply
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
repository_url = "crout1023172626-cn-beijing.cr.volces.com/verify/api"
repository_trn = "trn:cr:cn-beijing:2107436677:repository/crout1023172626/verify/api"

terraform -chdir=/tmp/cr-output-validation plan -detailed-exitcode
No changes. Your infrastructure matches the configuration.

terraform -chdir=/tmp/cr-output-validation destroy -auto-approve
Destroy complete! Resources: 3 destroyed.
```

## 6. 未完成项与限制

1. 线上 Provider `v0.0.71` 不支持 CR 生命周期策略、镜像扫描、CR IAM 策略和 `force_delete`。Provider 不回传 Repository URL/TRN；模块根据官方系统域名和 IAM TRN 格式派生这两个输出，并已完成 basic 真实云验证。
2. complete 示例当前使用命名空间作为机器人权限资源；此前真实云验证使用的是 `permissions.resource = "*"`。本次未复测命名空间资源格式，不能将旧验证结果外推至新权限配置。
3. 因不存在 `force_delete`，也没有可控的已推送测试镜像清理 API，本次未验证非空仓库删除策略。

## 7. 后续动作

1. 使用 complete 示例对命名空间范围的机器人权限执行真实 apply、二次 plan、destroy 和推拉验证。
2. Provider 支持生命周期、扫描、IAM 授权与非空仓库删除能力后，补充相应输入、实现与真实云验证。
