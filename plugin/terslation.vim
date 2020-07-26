" Terminal Translator interface for vim.
" Authors: SpringHan <springchohaku@qq.com> && Gnglas <2254228017@qq.com> for Terslation
" Last Change: 2020.7.26
" Version: 1.0.2
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
command! -nargs=0 TerslationWordTrans call s:OtherTranslate(0)
command! -nargs=0 -range TerslationSelectTrans call s:OtherTranslate(1)
" }}}

" FUNCTION: s:HighLightSet(...) {{{
function! s:HighLightSet(...) abort
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
	let l:translateContext = matchstr(getline(3),
				\ '\(Enter\sthe\stext:\s\|输入需要翻译的文本:\s\)\@<=\(.*\)')
	call setline(4, '')
	call setline(5, trim(system('terlat ' . '"' . l:translateContext . '"')))
	call cursor(5, 1)
	unlet l:translateContext
endfunction " }}}

" FUNCTION: s:resultYank() {{{
function! s:resultYank() abort
	let l:transResult = getline(5)
	if l:transResult == ''
		echohl Error | echom '[Terslation.vim]: There are no translation result!'
		echohl None
	endif
	call setreg(!exists('g:TerslationYank') || g:TerslationYank == 't' ? 't':
				\ g:TerslationYank, l:transResult, '"')
	unlet l:transResult
	call s:viewToggle()
endfunction " }}}

" FUNCTION: s:transFloatWin(transWord, ...) {{{
function! s:transFloatWin(transWord, ...) abort
	let l:floatBuf = nvim_create_buf(v:false, v:true)
	let l:transResult = trim(system('terlat ' . '"' . a:transWord . '"'))
	let l:width = strlen(l:transResult) <= 12 ? 14 : strlen(l:transResult) + 2
	let l:opt = { 'relative': 'cursor', 'width': l:width,
				\ 'height': 3, 'anchor': 'NW', 'col': 1, 'row': 1, }
	let l:window = nvim_open_win(l:floatBuf, v:false, l:opt)
	let l:context = [ '[Terslation]', '', l:transResult, ]

	call nvim_buf_set_lines(l:floatBuf, 0, 3, v:false, l:context)
	call nvim_win_set_option(l:window, 'number', v:false)
	call nvim_win_set_option(l:window, 'relativenumber', v:false)
	call nvim_buf_set_option(l:floatBuf, 'buftype', 'nofile')
	call s:HighLightSet(0)
	call nvim_buf_add_highlight(l:floatBuf, -1, 'TerslationTitle' , 0, 0, -1)
	call nvim_buf_add_highlight(l:floatBuf, -1, 'TerslationContext', 2, 0, -1)

	let g:TerslationFloatBuf = l:floatBuf
	unlet l:floatBuf l:transResult l:width l:opt l:window l:context
	if len(a:000) == 1
		silent execute "normal gv"
	endif
	autocmd CursorMoved,CursorMovedI * ++once silent! execute "bd " .
				\ g:TerslationFloatBuf . " | unlet g:TerslationFloatBuf"
endfunction " }}}

" FUNCTION: s:OtherTranslate(type) {{{
function! s:OtherTranslate(type) abort
	if a:type != 0 && a:type != 1
		return
	endif

	if a:type == 1
		let [ l:startLine, l:startCol ] = getpos("'<")[ 1 : 2 ]
		let [ l:endLine, l:endCol ] = getpos("'>")[ 1 : 2 ]
		let l:linesCont = getline(l:startLine, l:endLine)
		let l:linesCont[-1] = l:linesCont[-1][ : l:endCol - ( &selection ==
					\ 'inclusive' ? 1 : 2 ) ]
		let l:linesCont[0] = l:linesCont[0][ l:startCol - 1 : ]
		let l:transWord = l:linesCont[0]
		unlet l:linesCont l:startLine l:startCol l:endLine l:endCol
	else
		let l:transWord = expand('<cword>')
	endif

	if !exists('g:TerslationFloatWin') || g:TerslationFloatWin == 0
		call s:viewToggle(l:transWord)
	else
		execute a:type == 1 ? "call s:transFloatWin(l:transWord, 1)" : "call " .
					\ "s:transFloatWin(l:transWord)"
	endif
	unlet l:transWord
endfunction " }}}
