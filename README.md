# Ollama_question.nvim
This is a quick and dirty implementation to get a window open and you can talk to a Ollama hosted model

requires [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim/tree/master)

```
require("ollamachat").setup({
    url = "http://127.0.0.1:11434/api/generate"
})
```

replace the url with what ever your instances url is, if you want to use this you likely won't want to though.


I will not be fixing any thing and generally only will update it if I find issue within my use case. If you find an issue and want to use this as a base fork it and fix the issue for yourself.
