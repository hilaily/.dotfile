#!/usr/bin/env python3

import os
import sys
import platform
import subprocess
from typing import Dict, List, Optional
import urllib.request
import zipfile
import shutil

def get_font_dir() -> str:
    """根据操作系统确定字体安装目录"""
    system = platform.system()
    if system == "Darwin":  # macOS
        return os.path.expanduser("~/Library/Fonts")
    elif system == "Linux":
        return os.path.expanduser("~/.local/share/fonts")
    else:
        raise OSError(f"不支持的操作系统: {system}")

def check_command(command: str) -> bool:
    """检查命令是否存在"""
    return shutil.which(command) is not None

def download_file(url: str, dest_path: str) -> None:
    """下载文件到指定路径"""
    try:
        urllib.request.urlretrieve(url, dest_path)
    except Exception as e:
        print(f"下载失败: {e}")
        sys.exit(1)

def get_top_level_dirs(zip_file: zipfile.ZipFile) -> List[str]:
    """获取 ZIP 文件中的顶级目录"""
    return list(set(item.split('/')[0] for item in zip_file.namelist() if '/' in item))

def has_single_top_dir(zip_file: zipfile.ZipFile) -> bool:
    """检查 ZIP 文件是否只有一个顶级目录"""
    top_dirs = get_top_level_dirs(zip_file)
    return len(top_dirs) == 1 and all(name.startswith(top_dirs[0] + '/') for name in zip_file.namelist())


def unzip_file(zip_path: str, font_name: str) -> None:
    """解压文件到指定路径，根据 ZIP 文件结构决定是否创建顶级目录"""
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        if has_single_top_dir(zip_ref):
            # ZIP 文件有单一顶级目录，直接解压
            zip_ref.extractall("/tmp")
            print(f"已解压 {font_name} 到现有顶级目录")
        else:
            # 没有单一顶级目录，创建一个以字体名命名的目录
            font_dir = os.path.join("/tmp", font_name)
            os.makedirs(font_dir, exist_ok=True)
            for file in zip_ref.namelist():
                if not file.startswith('__MACOSX'):  # 排除 macOS 系统文件
                    zip_ref.extract(file, font_dir)
            print(f"已解压 {font_name} 并创建新的顶级目录")


def install_font(font_name: str, font_dir: str) -> None:
    """安装字体到指定目录"""
    # find ttf files to copy to the font_dir 
    ttf_files = [file for file in os.listdir(f"/tmp/{font_name}") if file.endswith(".ttf")]
    for ttf_file in ttf_files:
        shutil.copy(f"/tmp/{font_name}/{ttf_file}", font_dir)
    print(f"已安装 {font_name} 到 {font_dir}")

def refresh_font_cache() -> None:
    """在 Linux 系统上刷新字体缓存"""
    if platform.system() == "Linux" and check_command("fc-cache"):
        subprocess.run(["fc-cache", "-f"])
        print("字体缓存已刷新。")
    else:
        print("警告：无法刷新字体缓存。您可能需要手动刷新。")

def main() -> None:
    fonts: Dict[str, str] = {
        "SarasaNerd":"https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/download/v1.0.23-0/sarasa-fixed-sc-nerd-font.zip",
        "FiraCode": "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"   
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

