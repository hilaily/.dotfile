#!/usr/bin/env python3
# 下载并安装 Sarasa Nerd / Fira Code 字体到用户字体目录

import argparse
import os
import platform
import subprocess
import sys
import urllib.request
import zipfile
import shutil
from typing import Dict, List


def usage_text() -> str:
    return """用法: font-install

下载并安装以下字体到用户字体目录:
  - Sarasa Gothic Nerd (SC)
  - Fira Code

macOS: ~/Library/Fonts
Linux: ~/.local/share/fonts（安装后尝试 fc-cache）

选项:
  -h, --help  显示此帮助
"""


def get_font_dir() -> str:
    system = platform.system()
    if system == "Darwin":
        return os.path.expanduser("~/Library/Fonts")
    if system == "Linux":
        return os.path.expanduser("~/.local/share/fonts")
    raise OSError(f"不支持的操作系统: {system}")


def check_command(command: str) -> bool:
    return shutil.which(command) is not None


def download_file(url: str, dest_path: str) -> None:
    try:
        urllib.request.urlretrieve(url, dest_path)
    except Exception as e:
        print(f"下载失败: {e}")
        sys.exit(1)


def get_top_level_dirs(zip_file: zipfile.ZipFile) -> List[str]:
    return list(set(item.split("/")[0] for item in zip_file.namelist() if "/" in item))


def has_single_top_dir(zip_file: zipfile.ZipFile) -> bool:
    top_dirs = get_top_level_dirs(zip_file)
    return len(top_dirs) == 1 and all(
        name.startswith(top_dirs[0] + "/") for name in zip_file.namelist()
    )


def unzip_file(zip_path: str, font_name: str) -> None:
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        if has_single_top_dir(zip_ref):
            zip_ref.extractall("/tmp")
            print(f"已解压 {font_name} 到现有顶级目录")
        else:
            font_dir = os.path.join("/tmp", font_name)
            os.makedirs(font_dir, exist_ok=True)
            for file in zip_ref.namelist():
                if not file.startswith("__MACOSX"):
                    zip_ref.extract(file, font_dir)
            print(f"已解压 {font_name} 并创建新的顶级目录")


def install_font(font_name: str, font_dir: str) -> None:
    ttf_files = [
        file for file in os.listdir(f"/tmp/{font_name}") if file.endswith(".ttf")
    ]
    for ttf_file in ttf_files:
        shutil.copy(f"/tmp/{font_name}/{ttf_file}", font_dir)
    print(f"已安装 {font_name} 到 {font_dir}")


def refresh_font_cache() -> None:
    if platform.system() == "Linux" and check_command("fc-cache"):
        subprocess.run(["fc-cache", "-f"], check=False)
        print("字体缓存已刷新。")
    else:
        print("警告：无法刷新字体缓存。您可能需要手动刷新。")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="下载并安装 Sarasa Nerd / Fira Code 字体",
        add_help=False,
    )
    parser.add_argument("-h", "--help", action="store_true", help="显示帮助")
    args, _ = parser.parse_known_args()
    if args.help:
        print(usage_text())
        return

    fonts: Dict[str, str] = {
        "SarasaNerd": "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/download/v1.0.23-0/sarasa-fixed-sc-nerd-font.zip",
        "FiraCode": "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip",
    }

    try:
        font_dir = get_font_dir()
    except OSError as e:
        print(str(e))
        sys.exit(1)

    os.makedirs(font_dir, exist_ok=True)

    for font in fonts:
        print(f"正在下载和安装 {font}...")
        zip_path = f"/tmp/{font}.zip"
        download_file(fonts[font], zip_path)
        unzip_file(zip_path, font)
        install_font(font, font_dir)
        os.remove(zip_path)

    refresh_font_cache()
    print("安装完成。请重启您的终端或应用程序以使用新字体。")


if __name__ == "__main__":
    main()
