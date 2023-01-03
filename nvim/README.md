# Nvim config

##  Backup plugin version

Because nvim have some breaking changes sometimes. I can not alwaexys use the latest version of plugins.

### Backup

Execute `get_packer_snapshot.sh`. And it will open vim, you should exit vim, and then it will backup all the plugin commit information to a json file.

### Restore

document: https://github.com/wbthomason/packer.nvim#usage 

```
vim +"PackerSnapshot lock-${version}.json"
```



