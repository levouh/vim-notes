" Verification {{{1

    if exists('g:_loaded_notes')
        finish
    endif

    let g:_loaded_notes = 1

" Variables {{{1

    let g:notes_dir = '~/notes'
    let g:notes_todo_file = 'todo'
    let g:notes_extension = '.nt'

" Commands {{{1

    " View all current tasks, meaning only those that are
    " currently being worked on. Unlike "TODO" tasks, these
    " are just those that are like:
    "   [~] Task that is todo now +tag
    command! -nargs=* Todo call notes#get_todo(v:true, <q-args>)

    " View all tasks that are currently marked at "TODO"
    "
    " A task that is currently "TODO"
    " will be like:
    "   [-|~] Task that is todo +tag
    " meaning that there is a '-' or a '~' character.
    " A task that is not currently being worked on will be like:
    "   [ ] Task that is not todo +tag
    command! -nargs=* TodoAll call notes#get_todo(v:false, <q-args>)

    " View tasks with the input tag
    command! -nargs=1 TodoTag call notes#find_tasks_by_tag(<q-args>)

    " Create a new task
    command! NewTask call notes#new_task()

    " Toggle the todo status of the current line, for a definition
    " of what tasks are "TODO", see above
    command! -nargs=* ToggleTodo call notes#toggle_todo(<q-args>)

    if executable('fzf') && exists('g:notes_dir') && isdirectory(expand(g:notes_dir))
        " Edit a particular notes file, determined by note-based
        " settings for the base directory to search from
        command! -bang Note call fzf#vim#files(g:notes_dir,
                    \ fzf#vim#with_preview({'options': '--layout=reverse'}),
                    \ <bang>0)
    endif

" Mappings {{{1

    " Edit a notes file, which are defined as any files
    " found in the "g:_notes_dir" directory if it exists
    nnoremap <silent> <leader>n :Note<CR>

    " While editing the file defined by:
    "   g:_notes_dir .. '/' .. g:_notes_task_file
    " toggle the "TODO" status of the item on the current line.
    nnoremap <silent> <leader>- :ToggleTodo -<CR>
    nnoremap <silent> <leader>x :ToggleTodo ~<CR>
    nnoremap <silent> <leader><Space> :ToggleTodo<CR>

" Highlights {{{1

    hi! NtTag ctermfg=242 ctermbg=NONE guifg=#1E1E1E guibg=NONE cterm=NONE

    hi! NtNow ctermfg=255 ctermbg=NONE guifg=#F0F0F0 guibg=NONE cterm=NONE
    hi! NtSoon ctermfg=246 ctermbg=NONE guifg=#7C7C7C guibg=NONE cterm=NONE
    hi! NtLater ctermfg=242 ctermbg=NONE guifg=#1E1E1E guibg=NONE cterm=NONE
