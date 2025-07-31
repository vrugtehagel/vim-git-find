vim9script

const git_exists = system('command -v git')
if !git_exists | finish | endif

def StartsWith(long: string, short: string): bool
	return long->slice(0, len(short)) == short
enddef

def GitRevParse(from: string): string
	const original_dir = execute('cd')->trim()
	execute('cd ' .. from)
	const command = 'git rev-parse --show-toplevel 2>/dev/null'
	silent const toplevel = system(command)->trim()
	execute('cd ' .. original_dir)
	return toplevel
enddef

def GitLsFiles(from: string, gitignore: string): list<string>
	const original_dir = execute('cd')->trim()
	var command = 'git ls-files -c -o'
	if filereadable(gitignore)
		command = command .. ' -X ' .. gitignore
	endif
	execute('cd ' .. from, 'silent')
	silent const files = system(command)->split('\n')
	execute('cd ' .. original_dir)
	return files
enddef

def ListFiles(lead: string, full: string, position: number): list<string>
	var path = full->slice(2)->trim()
	const dir = expand('%:p:h')
	const toplevel = GitRevParse(dir)
	const input_path = path
	if toplevel == '' | return [] | endif
	var search_dir = toplevel
	var relative_parts = dir->split('/', 1)
	const amount_of_parts_originally = len(relative_parts)
	while StartsWith(path, './') || StartsWith(path, '../')
		if StartsWith(path, '../') | relative_parts->remove(-1) | endif
		path = path->trim('.', 1)->slice(1)
	endwhile
	var steps_up = -1
	if path != input_path
		if len(relative_parts) == 0 | relative_parts->add('') | endif
		search_dir = relative_parts->join('/')
		steps_up = amount_of_parts_originally - len(relative_parts)
	endif
	const gitignore = toplevel .. '/.gitignore'
	if !StartsWith(search_dir, toplevel) | return [] | endif
	const files = GitLsFiles(search_dir, gitignore)
	if path == '' | return files | endif
	var matches = files->matchfuzzy(path)
	if steps_up == -1 | return matches | endif
	var suffix = '../'->repeat(steps_up)
	if steps_up == 0 | suffix = './' | endif
	return matches->map((index, match) => suffix .. match)
enddef

def GotoFile(bang: string, query: string): void
	const paths = ListFiles('', query, 0)
	if len(paths) == 0
		echo 'No matches'
		return
	endif
	const dir = expand('%:p:h')
	var path = paths[0]
	echo path
	if StartsWith(path, './') || StartsWith(path, '../')
		path = dir .. '/' .. path
	else
		path = GitRevParse(dir) .. '/' .. path
	endif
	echo path
	execute('edit' .. bang .. ' ' .. path)
enddef

command! -nargs=1 -bang -complete=customlist,ListFiles GF call GotoFile('<bang>', <f-args>)
