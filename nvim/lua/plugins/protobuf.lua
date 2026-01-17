return {
	-- Protocol Buffers 支持通过以下方式提供：
	-- 1. 语法高亮：通过 treesitter（需要在 treesitter.lua 中添加 "proto"）
	-- 2. LSP 支持：通过 bufls（已在 nvim-lspconfig.lua 和 mason.lua 中配置）
	-- 
	-- 如果需要额外的语法高亮插件，可以使用：
	-- {
	-- 	"protocolbuffers/protobuf",
	-- 	ft = { "proto" },
	-- },
}

