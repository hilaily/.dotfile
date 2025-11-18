# ----- Git worktree native completions -----

# 列出分支
function __git_branches
    git branch --format="%(refname:short)" 2>/dev/null
end

# 列出 worktree 路径
function __git_worktree_paths
    git worktree list --porcelain 2>/dev/null \
        | awk '/worktree/ {print $2}'
end

# -----------------------
#   Worktree 别名补全
# -----------------------

# git wtl → worktree list
complete -f -c git -n '__fish_seen_subcommand_from wtl' -a ''

# git wtp → worktree prune
complete -f -c git -n '__fish_seen_subcommand_from wtp' -a ''

# git wta → worktree add <path> <branch>
complete -c git -n '__fish_seen_subcommand_from wta' \
    -a '(__git_branches)' \
    -d "Branch to add worktree for"

# git wtb → worktree add -b <newbranch> <path> <base>
complete -c git -n '__fish_seen_subcommand_from wtb' \
    -a '(__git_branches)' \
    -d "Base branch to create new branch from"

# git wtr → worktree remove <path>
complete -c git -n '__fish_seen_subcommand_from wtr' \
    -a '(__git_worktree_paths)' \
    -d "Existing worktree paths"

# ------------------------------
# 原生 git worktree 补全增强
# ------------------------------

# git worktree add <path> <branch>
complete -c git -n '__fish_seen_subcommand_from worktree; and __fish_seen_subcommand_from add' \
    -a '(__git_branches)' \
    -d "Branch to checkout"

# git worktree remove <path>
complete -c git -n '__fish_seen_subcommand_from worktree; and __fish_seen_subcommand_from remove' \
    -a '(__git_worktree_paths)' \
    -d "Worktree path"
