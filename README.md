<!-- -*- mode:gfm; code:utf-8 -*- -->

.myconfig
========

The .myconfig directory



Usage
-----

1. Clone https://github.com/wak109/.myconfig.git to your home directory.


   ``` sh
   $ git clone https://github.com/wak109/.myconfig.git
   ```

   .myconfig directory will be created.


2. Create symbilic links.


   ``` sh
   $ ln -s .myconfig/.screenrc
   $ ln -s .myconfig/.xinitrc
   $ ln -s .myconfig/.shrc .bashrc
   $ ln -s .myconfig/.shrc .bash_profile
   ```

2. (OPTIONAL) Create the file (~/.pathlist) to add more paths to PATH environment variable.
   Windows PATH cnd Unix PATH an be mixed up for MSYS and Cygwin.


   ``` .pathlist
   c:\\Windows\\System32
   c:\\Program Files (x86)\\Microsoft SDKs\\F#\\4.0\\Framework\\v4.0
   c:\\Program Files\\nodejs
   c:\\Program Files (x86)\\Java\\jre7\\bin
   /usr/local/bin
   ```

3. (OPTIONAL) Create the shell script file (~/.shext) to execute an additional script.
