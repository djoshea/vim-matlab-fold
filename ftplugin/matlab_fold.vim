" Vim folding file for Matlab .m files
" Language: Matlab  
" Author: Dan O'Shea <dan at djoshea.com>   
" Last Change:  2012 Jan 15
" Version:  1.0
"
" This plugin uses the indentation of your matlab code to know where to
" indent. Therefore, your function code must be indented with respect to the
" function keyword line which precedes it in order to be foldable. Also, this
" method doesn't deal with empty blocks correctly (e.g. a function with no
" body), since it doesn't know that there would be further indented code
" within.
"
" The code looks for end keywords to know where to end folds. Line
" continuations ... and comments are handled gracefully. Editor cells
" (beginning with %%) are also foldable even though the contents need 
" not be indented.
"
" This folding works best when the Matlab syntax and indent plugins authored
" by Fabrice Guy are also installed, which can be downloaded here:
"
"     http://www.vim.org/scripts/script.php?script_id=2407
"
" Install:
"   - Place this file in ~/.vim/ftplugin/ or
"       ~/.vim/bundle/vim-matlab-fold/ftplugin/ if you're using Pathogen
"
"   - Make sure you have the following lines in your .vimrc
"       filetype plugin on 
"       filetype indent on
"

setlocal foldmethod=expr
setlocal foldexpr=MatlabFoldExpr()

setlocal foldtext=MatlabFoldText()
setlocal fillchars=  " 

" set this to something low (like 0 - 2 range) to start with some folds closed
setlocal foldlevel=20

function! GetLineIndent(lnum, ...)
    " Get the indent of line lnum. This function automatically takes ... line 
    " continuation into account using recursion on the previous line (by
    " default, unless a second argument is provided). Blank lines are
    " considered indented by the maximum of their surrounding lines indents.
    "
    " The optional second argument forces the recursive calculation of line
    " indents to proceed in a specific direction, which is only used
    " internally to handle blank lines and line continuations (...). If the
    " second argument is specified as 1, the recursion will precede
    " forward; if specified as -1 it preceeds backwards in the file, else it
    " proceeds in both directions for blank lines, taking the maximum in
    " either direction.
    
    " check for optional second argument
    if a:0 > 0
        let directionForward = a:1
    else
        let directionForward = 0
    end

    " useful for debugging. Use :mess to see these messages
    " echom 'Finding indent for Line ' a:lnum ' with directionForward = ' directionForward 

    " does the line begin with %%? Specifically mark as indent 1 to prevent it
    " from being treated as an ordinary blank line
    if IsLineCellMarked(a:lnum)
        return 1

    " is this line blank OR a continuation of the previous line?
    " the ternary operator and sum is a hacked OR operator. Is there an || operator?
    elseif (IsLineBlank(a:lnum)?1:0) + (IsLineContinuedOnNext(a:lnum-1)?1:0) > 0

        if directionForward == 0
            " For blank lines, return the indent of the most indented surrounding line
            " Use the second argument to force the recursion to proceed in a
            " specific direction outward from this line 
            return max([GetLineIndent(nextnonblank(a:lnum+1),1), GetLineIndent(prevnonblank(a:lnum-1),-1)]) 

        elseif directionForward == 1
            " Just check the subsequent line
            return GetLineIndent(nextnonblank(a:lnum+1), 1)
        else " directionForward == -1 
            " Just check the previous line
            return GetLineIndent(prevnonblank(a:lnum-1), -1)
        end

    else
        " Nothing special, just return the actual indent + 1, which allows for 
        " cell-mode folding of unindented lines
        return indent(a:lnum) + 1 

        " if you're trying to debug, i'd recommend changing the above to:
        " return indent(a:lnum) / &ts + 1
        " to make the indent levels equal to the number of tabs rather than
        " spaces, and then use set foldcolumn=10 to see the folds visually
    endif
endfunction

function! IsLineCellMarked(lnum)
    " Returns 1 iff this line begins with %%
    return getline(a:lnum)=~'^%%'
endfunction

function! IsLineCellStart(lnum)
    " Returns 1 iff this line begins with %% and starts a cell,
    " i.e. the previous line doesn't also start with %%
    if IsLineCellMarked(a:lnum) 
        if IsLineCellMarked(a:lnum-1)
            return 0
        else
            return 1
        end
    else
        return 0
    end
endfunction

function! IsLineBlank(lnum)
    " Returns 1 iff this line is blank or contains only a comment
    return getline(a:lnum)=~'^\s*\(%.*\)*$'
endfunction

function! IsLineEndKeyword(lnum)
    " Returns 1 iff this line contains the end keyword 
    " (followed possibly by a semicolon or a comment). 
    " NOTE: Doesn't work if the line has a comma , separating multiple commands.
    return getline(a:lnum)=~'^\s*end\s*;\=\s*\(%.*\)*$'
endfunction

function! IsLineContinuedOnNext(lnum)
    " Returns 1 iff this line ends in ... and continues on the next
    return getline(a:lnum)=~'\.\{3}\s*\(%.*\)*$'
endfunction

function! MatlabFoldExpr(...)
    " This function is called by vim to determine the folding structure of the
    " document, but you can also call it directly using:
    " :echo MatlabFoldExpr(lineNum)
    "
    " It will return a string number indicating the fold level of the
    " line, possibly preceded by a > or < if this line begins or ends a fold
    " with that indentation level. See :help fold-expr for details.
    
    " determine whether to use the first argument or v:lnum
    " allowing us to call this function directly or use it as foldexpr 
    if a:0 > 0
        let lnum = a:1
    else
        let lnum = v:lnum
    endif   

    if lnum == 1
        " first line is always a fold (as if it's the first cell)
        " this is mainly to facilitate subsequent code folding, otherwise you'd
        " need to scan the whole file looking for the first cell, marking lines
        " above this first cell as 0 and the lines below it as 1 or greater
        let f = '>'.GetLineIndent(nextnonblank(lnum+1))

    elseif IsLineCellStart(lnum)
        " %% cell starters start a fold
        let f = '>'.GetLineIndent(nextnonblank(lnum+1))

    elseif IsLineEndKeyword(lnum) 
        " this is an end keyword that terminates the fold 
        " mark this as <# where # is the indent of the fold's content
        let f = '<'.GetLineIndent(prevnonblank(lnum-1))

    elseif GetLineIndent(lnum) < GetLineIndent(nextnonblank(lnum+1)) 
        " next line has greater indent, thus this line starts a new fold
        " so mark this as ># where # is the indent of the fold's content
        let f = '>'.GetLineIndent(nextnonblank(lnum+1))

    else
        " this is normal inner content, intelligently calculate indent
        let f = GetLineIndent(lnum) 

    endif

    " Uncomment for debugging, use :mess to view
    "echom 'Line ' lnum ' : level = ' f 
    return f
endfunction

" This function is a modified version of code from the following post. Thanks Greg!
" http://www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold/
"
" It returns a string which the folded text block will be collapsed into, and 
" features the first line of the block, the number of lines folded up, and the
" percentage of the file which this fold comprises.
function! MatlabFoldText()
    
    " get first non-blank line
    let fs = v:foldstart
    while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
    endwhile

    if fs > v:foldend
        let line = getline(v:foldstart)
    else
        let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    endif

    let w = winwidth(0) - &foldcolumn - (&number ? 4 : 0)
    let foldSize = 1 + v:foldend - v:foldstart
    let foldSizeStr = " " . foldSize . " lines "
    let foldLevelStr = ' '
    let lineCount = line("$")
    let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
    let expansionString = repeat(" ", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
    return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
endfunction
