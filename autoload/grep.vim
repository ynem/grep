let s:options        = ['ignorecase', 'extended'] " grep option
let s:dirs_excluded  = ['.git',  '.svn', '.hg']   " dirctories for exclude
let s:files_excluded = ['*.swp', 'tags']          " files for exclude

function! grep#do(pattern, path)
    " backup current grepprg val(to restore)
    let grepprg_val_escaped_bak = substitute(&grepprg, ' ', '\\ ', 'g')
    execute 'set grepprg=' . s:MakeGrepprgVal()
    silent execute "grep " . shellescape(a:pattern) . ' ' . shellescape(a:path)
    " resttore previous grepprg val
    execute 'set grepprg=' . grepprg_val_escaped_bak
    if len(getqflist()) > 0
        copen
    endif

    redraw!

    return
endfunction

function! grep#excludeFile(file_path)
    for d in s:files_excluded
        if d ==# a:file_path
            echo s:files_excluded
            return 0
        endif
    endfor

    call add(s:files_excluded, a:file_path)
    echo s:files_excluded
    return 0
endfunction

function! grep#excludeDir(dir_path)
    for d in s:dirs_excluded
        if d ==# a:dir_path
            echo s:dirs_excluded
            return 0
        endif
    endfor

    call add(s:dirs_excluded, a:dir_path)
    echo s:dirs_excluded
    return 0
endfunction

function! grep#removeFileExcluded(file_path)
    call remove(s:files_excluded, a:file_path)
    echo s:files_excluded
    return 0
endfunction

function! grep#removeDirExcluded(dir_number)
    call remove(s:dirs_excluded, a:dir_number)
    echo s:dirs_excluded
    return 0
endfunction

function! grep#doByOperator(type)
    if a:type ==# 'v'
        execute "normal! `<v`>y"
    elseif a:type ==# 'char'
        execute "normal! `[v`]y"
    else
        return
    endif

    call grep#do("\\b" . @@ . "\\b", ".")
endfunction

function! s:MakeGrepprgVal()
    return 'grep\ ' . s:MakeGrepprgValPartOption()
                   \. s:MakeGrepprgValPartExcludeDirs()
                   \. s:MakeGrepprgValPartExcludeFiles() . '$*'
endfunction

function! s:MakeGrepprgValPartOption()
    let l:grepprg_val_options = '-rHan\ ' " quickfix need row number and file path.
    for o in s:options
        let l:grepprg_option = s:OptionToGrepprgOption(o)
        if l:grepprg_option ==# ''
            continue
        endif

        let l:grepprg_val_options = l:grepprg_val_options . l:grepprg_option . '\ '
    endfor

    return l:grepprg_val_options
endfunction

function! s:MakeGrepprgValPartExcludeDirs()
    let l:grepprg_val_exclude_dirs = ''
    for d in s:dirs_excluded
        let l:grepprg_val_exclude_dirs = l:grepprg_val_exclude_dirs . '--exclude-dir=' . shellescape(d) . '\ '
    endfor

    return l:grepprg_val_exclude_dirs
endfunction

function! s:MakeGrepprgValPartExcludeFiles()
    let l:grepprg_val_exclude_files = ''
    for f in s:files_excluded
        let l:grepprg_val_exclude_files = l:grepprg_val_exclude_files . '--exclude=' . shellescape(f) . '\ '
    endfor

    return l:grepprg_val_exclude_files
endfunction

" convert grep option to grepprgval option
function! s:OptionToGrepprgOption(option)
    if a:option ==# 'ignorecase'
        return '-i'
    elseif a:option ==# 'extended'
        return '-E'
    endif

    return ''
endfunction

