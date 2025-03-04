"============================================================================
"File:        eslint.vim
"Description: Javascript syntax checker - using eslint
"Maintainer:  Maksim Ryzhikov <rv.maksim at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_javascript_eslint_checker')
    finish
endif
let g:loaded_syntastic_javascript_eslint_checker = 1

if !exists('g:syntastic_javascript_eslint_sort')
    let g:syntastic_javascript_eslint_sort = 1
endif

if !exists('g:syntastic_javascript_eslint_generic')
    let g:syntastic_javascript_eslint_generic = 0
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_javascript_eslint_IsAvailable() dict
    if g:syntastic_javascript_eslint_generic
        call self.log('generic eslint, exec =', self.getExec())
    endif

    if !executable(self.getExec())
        return 0
    endif
    return g:syntastic_javascript_eslint_generic || syntastic#util#versionIsAtLeast(self.getVersion(), [0, 1])
endfunction

function! SyntaxCheckers_javascript_eslint_GetLocList() dict
    if !g:syntastic_javascript_eslint_generic
        call syntastic#log#deprecationWarn('javascript_eslint_conf', 'javascript_eslint_args',
            \ "'--config ' . syntastic#util#shexpand(OLD_VAR)")
    endif

    let makeprg = self.makeprgBuild({ 'args_before': (g:syntastic_javascript_eslint_generic ? '' : '-f compact') })

    let errorformat =
        \ '%E%f: line %l\, col %c\, Error - %m,' .
        \ '%W%f: line %l\, col %c\, Warning - %m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['guards'] })

    if !g:syntastic_javascript_eslint_generic
        if !exists('s:eslint_new')
            let s:eslint_new = syntastic#util#versionIsAtLeast(self.getVersion(), [1])
        endif

        if !s:eslint_new
            for e in loclist
                let e['col'] += 1
            endfor
        endif
    endif

    return loclist
endfunction

function! SyntaxCheckers_javascript_eslint_GetYarnExec()
    let yarn_bin = ''
    let eslint = 'eslint'
    if executable('yarn')
        let yarn_bin = split(system('yarn bin'), '\n')[0]
    endif
    if strlen(yarn_bin) && executable(yarn_bin . '/eslint')
        let eslint = yarn_bin . '/eslint'
    endif
    return eslint
endfunction

function! SyntaxCheckers_javascript_eslint_GetNpmExec()
    let yarn_bin = ''
    let eslint = 'eslint'
    if executable('npm')
        let npm_bin = split(system('npm bin'), '\n')[0]
    endif
    if strlen(npm_bin) && executable(npm_bin . '/eslint')
        let eslint = npm_bin . '/eslint'
    endif
    return eslint
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'eslint',
    \ 'exec': SyntaxCheckers_javascript_eslint_GetNpmExec() })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
