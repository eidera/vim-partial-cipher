" File: plugin/partial_cipher.vim
" Author: eidera
" Version: 0.1
" Last Change: 17-Mar-2018.
" Written By: eidera
" First Release: Mar 17, 2018

" include guard {{{
if exists('loaded_partial_cipher') || &cp
    finish
endif
let loaded_partial_cipher=1
" }}}
" Global variables {{{
if !exists('partial_cipher_crypter_enc')
    let partial_cipher_crypter_enc = 'aes-256-ctr'
endif
if !exists('partial_cipher_passwd_file_path')
    let partial_cipher_passwd_file_path = '${HOME}/.vim_partial_cipher_pass'
endif
if !exists('partial_cipher_target_encrypt_tag')
    let partial_cipher_target_encrypt_tag = 'decrypt'
endif
if !exists('partial_cipher_target_decrypt_tag')
    let partial_cipher_target_decrypt_tag = 'encrypt'
endif
if !exists('partial_cipher_target_files')
    let partial_cipher_target_files = '*.crypt.md'
endif
if !exists('partial_cipher_always_highlight')
    let partial_cipher_always_highlight = 1
endif
if !exists('partial_crypt_decrypt_hightlight_name')
    let partial_crypt_decrypt_hightlight_name = 'SpellBad'
endif
if !exists('partial_crypt_encrypt_hightlight_name')
    let partial_crypt_encrypt_hightlight_name = 'SpellRare'
endif
" }}}
" Script local function {{{
function! s:crypter(crypt_option, params)
    let value = a:params['value']

    let pass = ''
    let pass_option = ''
    if has_key(a:params, 'pass')
        let pass_option = 'pass:' . a:params['pass']
    else
        let pass_option = 'file:' . g:partial_cipher_passwd_file_path
    endif

    " escape of single quote
    let value = substitute(value, "'", "'\"'\"'", 'g')

    let command = "echo '" . value . "' | openssl enc -" . g:partial_cipher_crypter_enc . " " . a:crypt_option . " -base64 -A -pass " . pass_option
    let output = system(command)
    return substitute(output, '\n$', '', '')
endfunction

function! s:encrypter(params)
    return s:crypter('-e', a:params)
endfunction

function! s:decrypter(params)
    return s:crypter('-d', a:params)
endfunction

function! s:tag_crypter(targetTag, destTag, cryptFunctionName)
    let pos = getpos(".")
    " Match to multi line(\_.) and match as few as possible(\{-}).
    exe 'silent! %s@\(<' . a:targetTag . '>\)\(\_.\{-}\)\(</' . a:targetTag . '>\)@\="<' . a:destTag . '>" . ' . a:cryptFunctionName . '({"value": submatch(2)}) . "</' . a:destTag . '>"@g'
    call setpos('.', pos)
endfunction
" }}}

function! partial_cipher#tag_encrypter()
    call s:tag_crypter(g:partial_cipher_target_encrypt_tag, g:partial_cipher_target_decrypt_tag, 's:encrypter')
endfunction

function! partial_cipher#tag_decrypter()
    call s:tag_crypter(g:partial_cipher_target_decrypt_tag, g:partial_cipher_target_encrypt_tag, 's:decrypter')
endfunction

augroup partialCipherAutoCmd
    autocmd!

    exe 'autocmd BufRead ' . g:partial_cipher_target_files . ' call partial_cipher#tag_decrypter()'
    exe 'autocmd BufWritePre ' . g:partial_cipher_target_files . ' call partial_cipher#tag_encrypter()'
    exe 'autocmd BufWritePost ' . g:partial_cipher_target_files . ' call partial_cipher#tag_decrypter()'

    let decryptSyntax = 'syntax match PartialCryptDecrypt ' . "'" . '<' . g:partial_cipher_target_encrypt_tag . '>\_.\{-}<\/' . g:partial_cipher_target_encrypt_tag . '>' . "'"
    let encryptSyntax = 'syntax match PartialCryptEncrypt ' . "'" . '<' . g:partial_cipher_target_decrypt_tag . '>\_.\{-}<\/' . g:partial_cipher_target_decrypt_tag . '>' . "'"

    if g:partial_cipher_always_highlight
        exe 'autocmd BufRead,BufNew ' . '*' . ' ' . decryptSyntax
        exe 'autocmd BufRead,BufNew ' . '*' . ' ' . encryptSyntax
    else
        exe 'autocmd BufRead ' . g:partial_cipher_target_files . ' ' . decryptSyntax
        exe 'autocmd BufRead ' . g:partial_cipher_target_files . ' ' . encryptSyntax
    endif

    exe 'highlight def link PartialCryptDecrypt ' .  g:partial_crypt_decrypt_hightlight_name
    exe 'highlight def link PartialCryptEncrypt ' .  g:partial_crypt_encrypt_hightlight_name
augroup END
" vim: set fdm=marker :
