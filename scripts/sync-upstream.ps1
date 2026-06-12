# 将官方 CodexPlusPlus 的更新合并到本地 fork，并推送到 origin。
# 用法: .\scripts\sync-upstream.ps1

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

$UpstreamUrl = "git@github.com:BigPizzaV3/CodexPlusPlus.git"

if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
    throw "当前目录不是 Git 仓库: $Root"
}

$Status = git status --porcelain
if ($Status) {
    Write-Host "警告: 工作区有未提交改动，同步前建议先 commit 或 stash。" -ForegroundColor Yellow
    git status -sb
    $Continue = Read-Host "仍要继续? (y/N)"
    if ($Continue -ne "y" -and $Continue -ne "Y") {
        exit 1
    }
}

$Remotes = git remote
if ($Remotes -notcontains "upstream") {
    Write-Host "添加上游 remote: upstream" -ForegroundColor Cyan
    git remote add upstream $UpstreamUrl
}

Write-Host "拉取 upstream/main ..." -ForegroundColor Cyan
git fetch upstream main

Write-Host "合并到 main ..." -ForegroundColor Cyan
git checkout main
git merge upstream/main --no-edit -m "chore: sync upstream CodexPlusPlus"

Write-Host "推送到 origin ..." -ForegroundColor Cyan
git push origin main

Write-Host "同步完成。" -ForegroundColor Green
git log -1 --oneline
