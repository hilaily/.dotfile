func! myspacevim#before() abort
    set wrap
    "设置折叠方式
    set foldmethod=indent
    " 打开文件默认不折叠
    set foldlevelstart=99

    "大括号回车
    "inoremap { {<CR>}<up><end><CR>
    "逗号后加上空格
    "inoremap , ,<Space>
    "等号左右空格
    "inoremap = <Space>=<Space>
endf
