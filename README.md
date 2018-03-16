# Abstract

*partial-cipher* is a Vim plugin to provide the function to encrypt part of the text file.

Furthermore, when saving a file, it *AUTOMATICALLY* encrypts the target character string. When opening the file, it *AUTOMATICALLY* decrypts the encrypted character string.

The character string to be encrypted is a character string enclosed by the prescribed tag. You can change this tag with `g:partial_cipher_target_encrypt_tag` .


## For example:

```
sample text1
<decrypt>my password</decrypt>
sample text2
```

The text enclosed by <decrypt> and </decrypt> is encrypted and saved.


You can also call the function for manually encrypting or decrypting without calling it automatically.

```
call partial_cipher#tag_encrypter()
call partial_cipher#tag_decrypter()
```

## Requirements:
- Vim 8.0 or later
- Openssl command

## Latest version:
https://github.com/eidera/vim-partial-cipher

## For more information

See detail doc/partial-cipher.txt (:help partial-cipher)

# Example: `.vimrc`

```vim
let partial_cipher_crypter_enc = 'aes-256-ctr'
let partial_cipher_passwd_file_path = '${HOME}/.vim_partial_cipher_pass'
let partial_cipher_target_encrypt_tag = 'decrypt'
let partial_cipher_target_decrypt_tag = 'encrypt'
let partial_cipher_always_highlight = 1
let partial_cipher_target_files = '*.crypt.md'
let partial_crypt_decrypt_hightlight_name = 'SpellBad'
let partial_crypt_encrypt_hightlight_name = 'SpellRare'

nnoremap <C-W><C-P><C-E> :<C-U>call partial_cipher#tag_encrypter()<CR>
nnoremap <C-W><C-P><C-D> :<C-U>call partial_cipher#tag_decrypter()<CR>
exe 'vmap <C-W><C-P><C-T> S<' . g:partial_cipher_target_encrypt_tag . '>'
```
