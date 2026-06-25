# 供 script/*.sh source：统一处理 -h / --help
# 调用方需先定义 usage() 函数

dotfile_help_requested() {
    [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]
}

dotfile_show_help() {
    usage
    exit 0
}
