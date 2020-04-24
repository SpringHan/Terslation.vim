" Terminal Translator interface for vim.
" Authors: SpringHan <springchohaku@qq.com> && Gnglas <2254228017@qq.com>(Terslation)
" Last Change: 2020.4.14
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
command! -nargs=? TerslationToggle call s:viewToggle(<q-args>)
command! -nargs=0 TerslationTrans call s:translate()
command! -nargs=0 TerslationYank call s:resultYank()
command! -nargs=0 TerslationWordTrans call s:wordTranslate()
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
	syntax match TerslationContextHL /\(Enter\sthe\stext:\s\|输入需要翻译的文本:\s\)\@<=\(.*\)/
	if !exists('g:TerslationDefaultSyntax') || g:TerslationDefaultSyntax == 1
		highlight TerslationTitle ctermfg=167 guifg=#fb4934
		highlight TerslationAhead cterm=bold ctermfg=142 gui=bold guifg=#98C379
		highlight TerslationContext ctermfg=214 guifg=#fabd2f
	endif
	highlight link TerslationTitleHL TerslationTitle
	highlight link TerslationAheadHL TerslationAhead
	highlight link TerslationContextHL TerslationContext
endfunction " }}}

" Function: s:viewToggle(...) {{{
function! s:viewToggle(...) abort
	if exists('a:1') && a:1 == 1 "Refresh the interactive panel
		call deletebufline(s:viewBuf, 4, 5)
		call setline(3, !exists('g:TerslationLang') || g:TerslationLang ==# 'en'?
					\ 'Enter the text: ':'输入需要翻译的文本: ')
		call cursor(3, 0)
		startinsert!
		return
	endif
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
		if exists('a:1') && a:1 != '' && a:1 != 1
			call setline(3, !exists('g:TerslationLang') || g:TerslationLang ==# 'en'?
						\ 'Enter the text: '.a:1 : '输入需要翻译的文本: '.a:1)
			call s:translate()
		else
			call setline(3, !exists('g:TerslationLang') || g:TerslationLang ==# 'en'?
						\ 'Enter the text: ':'输入需要翻译的文本: ')
			call cursor(3, 0)
			startinsert!
		endif
		call s:HighLightSet()
		nnoremap <buffer><silent> <ESC> :TerslationToggle<CR>
		nnoremap <buffer><silent> <CR> :TerslationYank<CR>
		nnoremap <buffer><silent> i :TerslationToggle 1<CR>
		inoremap <buffer><silent> <ESC> <ESC>:TerslationToggle<CR>
		inoremap <buffer><silent> <CR> <ESC>:TerslationTrans<CR>
	else
		silent! execute "bd ".s:viewBuf
		unlet s:viewBuf
	endif
endfunction " }}}

" FUNCTION: translate() {{{
function! s:translate() abort
	let s:translateContext = matchstr(getline(3),
				\ '\(Enter\sthe\stext:\s\|输入需要翻译的文本:\s\)\@<=\(.*\)')
	call setline(4, '')
	call cursor(4, 0)
	call writefile([s:translateContext], '/usr/local/src/fanyi/.fanyi.txt', 'b')
	silent execute 'read !python3 /usr/local/src/fanyi/fanyi.py'
	unlet s:translateContext
endfunction " }}}

" FUNCTION: s:resultYank() {{{
function! s:resultYank() abort
	let l:transResult = getline(5)
	if l:transResult == ''
		echohl Error | echom '[Terslation.vim]: There are no translation result!'
		echohl None
	endif
	call setreg(!exists('g:TerslationYank') || g:TerslationYank == 't'?'t':
				\ g:TerslationYank, l:transResult, '"')
	unlet l:transResult
	call s:viewToggle()
endfunction " }}}

" FUNCTION: s:wordTranslate() {{{
function! s:wordTranslate() abort
	let l:transWord = expand('<cword>')
	call s:viewToggle(l:transWord)
	unlet l:transWord
endfunction " }}}
