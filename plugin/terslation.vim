" Terminal Translator interface for vim.
" Authors: SpringHan <springhan@qq.com> && Gnglas <2254228017@qq.com>
" Last Change: <+++>
" Version: 1.0.0
" Repository: https://github.com/SpringHan/Terslation.vim
" Lisence: MIT

" Autoload {{{
if exists('g:TerslationLoaded')
	finish
endif
let g:TerslationLoaded = 1
" }}}

" Commands {{{
command! -nargs=0 TerslationToggle call s:ViewToggle()
" }}}

" Function: s:ViewToggle() {{{
function! s:ViewToggle() abort
	if !exists('s:viewBuf')
		if !exists('g:TerslationPosition') && !exists('g:TerslationWidth')
			silent! execute "vertical botright 50new"
		else
			silent! execute !exists('g:TerslationPosition') ? "vertical botright ".
						\ g:TerslationWidth."new" : "vertical ".g:TerslationPosition." 50new"
			silent! execute exists('g:TerslationPosition') &&
						\ exists('g:TerslationWidth') ? "vertical ".g:TerslationPosition.
						\ " ".g:TerslationWidth : ""
		endif
		let s:viewBuf = bufnr('')
		setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
					\ modifiable statusline=>\ Terslation nocursorline nofoldenable
					\ norelativenumber
		noremap <ESC> :TerslationToggle<CR>
	else
		silent! execute "bd ".s:viewBuf
		unlet s:viewBuf
		unmap <ESC>
	endif
endfunction " }}}
