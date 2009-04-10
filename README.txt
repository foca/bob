Bob the Builder
===============

Given a Buildable object with the following public API:

- #repo_kind                               #=> :git, :svn, ...
- #repo_uri                                #=> "git://github.com/foca/bob.git"
- #repo_branch                             #=> "master"
- #build_script                            #=> "make test && make && make install"
- #start_building(commit_id, commit_info)
- #add_successful_build(commit_id, output)
- #add_failed_build(commit_id, output)

Bob will, when called like:

    Bob.build(buildable, commit_id)

1. Checkout the buildable on the specified commit
2. Call `buildable.start_building`
3. Run the script provided in `build_script` in the buildable.
4. If the script returns a status code of 0 it calls `add_successful_build` on the
   buildable with the appropriate arguments. If not, it calls `add_failed_build`.

Do I need this?
===============

Probably not. Check out http://integrityapp.com for a full fledged automated CI 
server, which is what most people need.

License
=======

(The MIT License)

Copyright (c) 2008-2009 Nicolás Sanguinetti, entp.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
