#!/usr/bin/env python3
# 按类别增量更新 /etc/docker/daemon.json（仅补缺失项，不覆盖已有配置）

from __future__ import annotations

import argparse
import copy
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

DAEMON_JSON = Path("/etc/docker/daemon.json")
PATCH_DIR_NAME = Path("docker") / "daemon.d"

CATEGORIES: dict[str, str] = {
    "base": "日志轮转等基础项（log-driver / log-opts）",
    "mirror": "镜像加速（registry-mirrors）",
}


def dotfile_root() -> Path:
    return Path(__file__).resolve().parent.parent


def usage_text() -> str:
    cats = "\n".join(f"  {name:<8} {desc}" for name, desc in CATEGORIES.items())
    return f"""用法: docker-daemon-config [选项] [类别 ...]

将 ~/.dotfile/docker/daemon.d/ 下对应片段合并进 /etc/docker/daemon.json。
已有 key 保留不变；仅插入缺失的 key（嵌套对象递归补全）。

类别:
{cats}
  all      应用上述全部类别

示例:
  sudo ff script docker-daemon-config base
  sudo ff script docker-daemon-config mirror
  sudo ff script docker-daemon-config all
  sudo ff script docker-daemon-config base --dry-run

选项:
  -h, --help    显示此帮助
  --list        列出可用类别
  --dry-run     只打印合并结果，不写文件
  --no-backup   不备份现有 daemon.json
  --no-restart  合并后不尝试 reload/restart docker
"""


def fill_missing(base: Any, patch: Any) -> Any:
    """仅补 patch 中有、base 中没有的 key；已有 key 不覆盖。"""
    if not isinstance(patch, dict):
        return base
    if not isinstance(base, dict):
        return copy.deepcopy(patch)

    out = copy.deepcopy(base)
    for key, patch_value in patch.items():
        if key not in out:
            out[key] = copy.deepcopy(patch_value)
        elif isinstance(out[key], dict) and isinstance(patch_value, dict):
            out[key] = fill_missing(out[key], patch_value)
    return out


def load_json(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8").strip()
    if not text:
        return {}
    data = json.loads(text)
    if not isinstance(data, dict):
        raise ValueError(f"{path} 根节点必须是 JSON 对象")
    return data


def resolve_categories(names: list[str]) -> list[str]:
    if not names:
        return []
    if "all" in names:
        return list(CATEGORIES.keys())
    unknown = [name for name in names if name not in CATEGORIES]
    if unknown:
        raise ValueError(f"未知类别: {', '.join(unknown)}")
    # 去重并保持顺序
    seen: set[str] = set()
    ordered: list[str] = []
    for name in names:
        if name not in seen:
            seen.add(name)
            ordered.append(name)
    return ordered


def patch_path(root: Path, category: str) -> Path:
    return root / PATCH_DIR_NAME / f"{category}.json"


def collect_patches(root: Path, categories: list[str]) -> dict[str, dict[str, Any]]:
    patches: dict[str, dict[str, Any]] = {}
    for category in categories:
        path = patch_path(root, category)
        if not path.is_file():
            raise FileNotFoundError(f"缺少配置片段: {path}")
        patches[category] = load_json(path)
    return patches


def diff_added(before: dict[str, Any], after: dict[str, Any], prefix: str = "") -> list[str]:
    added: list[str] = []
    for key, value in after.items():
        path = f"{prefix}{key}"
        if key not in before:
            added.append(path)
            continue
        if isinstance(value, dict) and isinstance(before.get(key), dict):
            added.extend(diff_added(before[key], value, prefix=f"{path}."))
    return added


def validate_daemon_json(path: Path) -> None:
    with path.open(encoding="utf-8") as fh:
        json.load(fh)

    dockerd = shutil.which("dockerd")
    if not dockerd:
        return
    try:
        subprocess.run(
            [dockerd, "--validate", "--config-file", str(path)],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
        )
    except subprocess.CalledProcessError as exc:
        detail = (exc.stderr or "").strip()
        raise RuntimeError(f"dockerd --validate 失败: {detail or exc}") from exc


def reload_docker() -> None:
    if shutil.which("systemctl") is None:
        print("[INFO] 未找到 systemctl，请手动重启 Docker 使配置生效")
        return

    for action in ("reload", "restart"):
        result = subprocess.run(
            ["systemctl", action, "docker"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        if result.returncode == 0:
            print(f"[INFO] 已执行 systemctl {action} docker")
            return

    print("[WARN] systemctl reload/restart docker 失败，请手动重启 Docker")
    if result.stdout.strip():
        print(result.stdout.strip())


def write_daemon_json(content: dict[str, Any], dry_run: bool, backup: bool) -> None:
    serialized = json.dumps(content, indent=2, ensure_ascii=False) + "\n"

    if dry_run:
        print(serialized)
        return

    if os.geteuid() != 0:
        print("[ERROR] 写入 /etc/docker/daemon.json 需要 root，请使用 sudo 运行")
        sys.exit(1)

    DAEMON_JSON.parent.mkdir(parents=True, exist_ok=True)

    tmp_path = DAEMON_JSON.with_suffix(".json.tmp")
    tmp_path.write_text(serialized, encoding="utf-8")
    try:
        validate_daemon_json(tmp_path)
    except Exception:
        tmp_path.unlink(missing_ok=True)
        raise

    if backup and DAEMON_JSON.is_file():
        stamp = datetime.now().strftime("%Y%m%d%H%M%S")
        backup_path = DAEMON_JSON.with_name(f"{DAEMON_JSON.name}.bak.{stamp}")
        shutil.copy2(DAEMON_JSON, backup_path)
        print(f"[INFO] 已备份到 {backup_path}")

    tmp_path.replace(DAEMON_JSON)
    os.chmod(DAEMON_JSON, 0o644)
    print(f"[INFO] 已写入 {DAEMON_JSON}")


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("categories", nargs="*", help="要应用的类别")
    parser.add_argument("-h", "--help", action="store_true")
    parser.add_argument("--list", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-backup", action="store_true")
    parser.add_argument("--no-restart", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)

    if args.help:
        print(usage_text())
        return 0

    if args.list:
        for name, desc in CATEGORIES.items():
            print(f"{name}\t{desc}")
        print("all\t应用全部类别")
        return 0

    try:
        categories = resolve_categories(args.categories)
    except ValueError as exc:
        print(f"[ERROR] {exc}")
        print("可用类别:", ", ".join([*CATEGORIES.keys(), "all"]))
        return 1

    if not categories:
        print(usage_text())
        return 1

    root = dotfile_root()
    patch_root = root / PATCH_DIR_NAME
    if not patch_root.is_dir():
        print(f"[ERROR] 配置目录不存在: {patch_root}")
        return 1

    existing: dict[str, Any] = {}
    if DAEMON_JSON.is_file():
        try:
            existing = load_json(DAEMON_JSON)
        except json.JSONDecodeError as exc:
            print(f"[ERROR] {DAEMON_JSON} 不是合法 JSON: {exc}")
            return 1

    try:
        patches = collect_patches(root, categories)
    except (FileNotFoundError, ValueError) as exc:
        print(f"[ERROR] {exc}")
        return 1

    merged = copy.deepcopy(existing)
    for category in categories:
        before = copy.deepcopy(merged)
        merged = fill_missing(merged, patches[category])
        added = diff_added(before, merged)
        if added:
            print(f"[INFO] 类别 {category} 新增: {', '.join(added)}")
        else:
            print(f"[INFO] 类别 {category} 无需变更（相关项已存在）")

    if merged == existing:
        print("[INFO] daemon.json 无变化")
        return 0

    try:
        write_daemon_json(merged, dry_run=args.dry_run, backup=not args.no_backup)
    except Exception as exc:
        print(f"[ERROR] {exc}")
        return 1

    if not args.dry_run and not args.no_restart:
        reload_docker()

    return 0


if __name__ == "__main__":
    sys.exit(main())
