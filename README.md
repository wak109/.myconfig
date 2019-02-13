<!-- -*- mode:gfm; code:utf-8 -*- -->

.myconfig
========

Quick setup for shell environment.



Usage
-----

1. Clone https://github.com/wak109/.myconfig.git to your home directory.


   ``` sh
   $ git clone https://github.com/wak109/.myconfig.git
   ```

   .myconfig directory will be created.


2. Create symbilic links.

   - msys2

   ``` sh
   $ mklink .tmux.conf .myconfig\.tmux.conf
   $ mklink .xinitrc .myconfig\.xinitrc
   $ mklink .bashrc .myconfig/.bashrc
   $ mklink .bash_profile .myconfig\.bashrc
   ```
   (Run cmd.exe as Administrator)


   - Linux

   ``` sh
   $ ln -s .myconfig/.tmux.conf
   $ ln -s .myconfig/.xinitrc
   $ ln -s .myconfig/.bashrc .bashrc
   $ ln -s .myconfig/.bashrc .bash_profile
   ```

3. (OPTIONAL) Create the file (~/.pathlist) to add more paths
   to PATH environment variable.

   Windows PATH, Unix PATH, mixed up PATH for MSYS and Cygwin can be used.

   ``` .pathlist
   c:\\Windows\\System32
   c:\\Program Files (x86)\\Microsoft SDKs\\F#\\4.0\\Framework\\v4.0
   c:\\Program Files\\nodejs
   c:\\Program Files (x86)\\Java\\jre7\\bin
   /usr/local/bin
   ```

3. (OPTIONAL) Create the shell script file (~/.shext) to
   execute an additional script.
