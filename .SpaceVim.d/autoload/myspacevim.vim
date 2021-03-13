lua << EOF
    local c = require('custom')
    lcustom.init()
EOF

function! myspacevim#before() abort
    set wrap
    "设置折叠方式
    set foldmethod=indent
    " 打开文件默认不折叠
    set foldlevelstart=99
    let g:go_metalinter_autosave=0
    let g:XkbSwitchEnabled = 1

    "nnoremap <Space>k :<C-u>call gitblame#echo()<CR>

    "大括号回车
    "inoremap { {<CR>}<up><end><CR>
    "逗号后加上空格
    "inoremap , ,<Space>
    "等号左右空格
    "inoremap = <Space>=<Space>
endfunction
