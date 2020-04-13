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

" FUNCTION: s:HighLightSet() {{{
function! s:HighLightSet() abort
	syntax clear
	syntax match TerslationTitleHL /^\[Terslation\]/
	if !exists('g:TerslationLang') || g:TerslationLang ==# 'en'
		syntax match TerslationAheadHL /^Enter\sthe\stext/
	else
		syntax match TerslationAheadHL /^输入需要翻译的文本/
	endif
	syntax match TerslationContextHL /\(Enter\sthe\stext:\|输入需要翻译的文本:\)\@<=\s\(.*\)/
	if !exists('g:TerslationDefaultSyntax') || g:TerslationDefaultSyntax == 1
		highlight TerslationTitle ctermfg=167 guifg=#fb4934
		highlight TerslationAhead cterm=bold ctermfg=142 gui=bold guifg=#98C379
		highlight TerslationContext ctermfg=214 guifg=#fabd2f
	endif
	highlight link TerslationTitleHL TerslationTitle
	highlight link TerslationAheadHL TerslationAhead
	highlight link TerslationContextHL TerslationContext
endfunction " }}}

" Function: s:ViewToggle() {{{
function! s:ViewToggle() abort
	if !exists('s:viewBuf')
		if !exists('g:TerslationPosition') && !exists('g:TerslationWidth')
			silent execute "vertical botright 50new"
		else
			silent execute !exists('g:TerslationPosition') ? "vertical botright ".
						\ g:TerslationWidth."new" : "vertical ".g:TerslationPosition." 50new"
			silent execute exists('g:TerslationPosition') &&
						\ exists('g:TerslationWidth') ? "vertical ".g:TerslationPosition.
						\ " ".g:TerslationWidth : ""
		endif
		let s:viewBuf = bufnr('')
		setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
					\ modifiable statusline=>\ Terslation nocursorline nofoldenable
					\ norelativenumber
		call setline(1, '[Terslation]')
		call setline(2, '')
		call setline(3, !exists('g:TerslationLang') || g:TerslationLang ==# 'en'?
					\ 'Enter the text: ':'输入需要翻译的文本: ')
		call cursor(3, 0)
		call s:HighLightSet()
		nnoremap <buffer><silent> <ESC> :TerslationToggle<CR>
		inoremap <buffer><silent> <ESC> <ESC>:TerslationToggle<CR>
		inoremap <buffer><silent> <CR> :call Terslation#translate()<CR>
		startinsert!
	else
		silent! execute "bd ".s:viewBuf
		unlet s:viewBuf
	endif
endfunction " }}}
