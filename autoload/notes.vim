fu! notes#get_todo(current, ...) abort " {{{1
    let task_file = s:get_todo_file()

    if task_file is# v:none
        return
    endif

    " The tasks file is returned relative to the root directory,
    " so do the same for the name of the current buffer
    if fnamemodify(bufname(), ":p") != task_file
        echoerr 'ERROR: Not in "' .. task_file .. '" file!' | return
    endif

    let tags_str = ''

    " Only search for an '~' character if just looking for current
    " tasks
    let marker = a:current is# v:true ? '~' : '\-|~'

    " Identifier for a todo item
    let pat = '\[(' .. marker .. ')\]'

    if a:0 && !empty(a:1)
        " Split the passed arguments on a space, and then prepend
        " '+' character to each of them as this is how tags are
        " formatted in the tasks file.
        "
        " Finally, as there can be multiple, join them with a '|'
        " to denote that any of the passed tags should be matched
        " with any characters up to a whitespace character after the
        " tag.
        let tags = join(map(split(a:1, ' '), '"\\+" .. v:val .. "([^\\s]*)"'), "\|")

        " Define this 'tag match' as an atom
        let tags_str = "(" .. tags .. ")"
    endif

    " Search for lines starting with '@', don't jump to first match
    "
    "            ┌ populate location list with results of a search
    "            │ ┌ begin a search
    "            │ │  ┌ start of line
    "            │ │  │
    let re_str = 'lv /\v^\s*' .. pat .. '.*' .. tags_str .. '/j ' .. task_file
    "                     │       │                           │
    "                     │       │                           └ don't jump to the first match
    "                     │       └ pattern for a todo item
    "                     └ any amount of whitespace

    echom re_str

    try
        " Now evaluate the string to potentially populate the location list
        silent exe re_str
    catch | | endtry

    if !len(getloclist(0)) > 0
        " Nothing was found, return now
        redraw | echo 'Nothing TODO' | return
    endif

    " Something was found, show the results in the location list
    lwindow
endfu

fu! notes#find_tasks_by_tag(tag) " {{{1
    " Find tasks by a given tag.
    "
    " Tasks in the 'tasks file' will be written like:
    "   > Do something +tag
    " so this function will populate the location list
    " with all lines that have the entered tag
    let l:task_file = s:get_todo_file()

    if l:task_file is# v:none
        return
    endif

    " The tasks file is returned relative to the root directory,
    " so do the same for the name of the current buffer
    if fnamemodify(bufname(), ":p") != l:task_file
        echoerr 'ERROR: Not in "' .. l:task_file .. '" file!' | return
    endif

    " Identifier for a task item
    let pat = '\[.\]'

    try
        " Search for lines matching the specified tag, put them
        " in the location list
        "
        " See "get_todo()" for explanation of regex pattern
        silent exe 'lv /\v^\s*' .. pat .. '.*\+' .. a:tag .. '/j ' .. task_file
    catch | | endtry

    if !len(getloclist(0)) > 0
        redraw | echo 'No tasks for "' .. a:tag .. '" found' | return
    endif

    " Something was found, show the results in the location list
    lwindow
endfu

fu! notes#new_task() " {{{1
    " Let the user choose tags, create new task using the passed note
    let l:task_file = s:get_todo_file()

    if l:task_file is# v:none
        return
    endif

    " The tasks file is returned relative to the root directory,
    " so do the same for the name of the current buffer
    if fnamemodify(bufname(), ":p") != l:task_file
        echoerr 'ERROR: Not in "' .. l:task_file .. '" file!' | return
    endif

    " Have the user enter tags for the task
    let l:tags = map(
            \ split(input('Enter tags for new task: '), ' '),
            \ '"+" . v:val')

    let l:note = input('Enter the task description: ')
    let l:task_str = '    [ ] ' .. l:note .. ' ' .. join(l:tags, ' ')

    " Put the new task above the current line
    silent! put! =l:task_str
endfu

fu! notes#toggle_todo(...) " {{{1
    " Toggle the todo status of the current line
    let l:task_file = s:get_todo_file()

    if l:task_file is# v:none
        return
    endif

    " The tasks file is returned relative to the root directory,
    " so do the same for the name of the current buffer
    if fnamemodify(bufname(), ":p") != l:task_file
        echoerr 'ERROR: Not in "' .. l:task_file .. '" file!' | return
    endif

    let l:cur_line = getline('.')

    " If no arguments are passed, assume the task is being marked
    " as empty
    let task_marker = ''

    if a:0
        " Otherwise, mark it with the passed argument
        let task_marker = empty(a:1) ? ' ' : a:1
    endif

    " Identifier for a task item
    let pat = '\[.\]'

    " Replace the above with this pattern
    let new_pat = '\[' .. task_marker .. '\]'

    " Based on the passed argument, change the status of the
    " current line by replacing "pat" with "new_pat"
    call setline(line('.'), substitute(l:cur_line, '\v(^\s+)' .. pat, '\1' .. new_pat, ''))
    "                                                                  │
    "                                 keep whitespace from group match ┘
endfu
fu! s:get_todo_file() " {{{1
    " Return the string absolute path to the configured notes file,
    " or return "v:none" on an error
    if !exists('g:notes_dir')
        echoerr 'ERROR: No "g:notes_dir" variable setup' | return v:none
    endif

    if !isdirectory(g:notes_dir)
        echoerr 'ERROR: No "' .. g:notes_dir .. '" directory found' | return v:none
    endif

    if !exists('g:_notes_todo_file')
        echoerr 'ERROR: No "g:_notes_todo_file" variable setup' | return v:none
    endif

    "                             ┌ should just be a directory
    "                             │
    "                             │
    let l:todo_file = simplify(g:notes_dir .. '/' .. g:notes_todo_file)
    "                                                    │
    "                                                    │
    "                                                    └ the file withinn this directory

    if !filereadable(l:todo_file)
        echoerr 'ERROR: File "' .. l:todo_file .. '" not readable!' | return
    endif

    " Return relative to the root directory
    return fnamemodify(l:todo_file, ":p")
endfu

