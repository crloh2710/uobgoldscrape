lib_path = "/home/runner/work/_temp/Library"
dir.create(lib_path, recursive = T, showWarnings = F)
install.packages(c('netstat', 'rvest', 'remotes', 'chromote'), 
                 repos='https://cloud.r-project.org',
                lib = lib_path)

