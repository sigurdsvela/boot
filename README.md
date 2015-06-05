# boot
A command line tool for quickly creating starting points for projects based on different templates, containing boilerplate code

Boot contains different templates to create different types of projects([List all templates](#list-all-templates))

## Installation
**(Recomended)** Install from ruby gems
```shell
$ gem install boot-cli
```

Alternatively install the latest version with the install script
```shell
$ curl -sSL https://raw.github.com/sigurdsvela/boot/install.rb | ruby
```

## Usage

### Create new project
To create a new project base on a template run
```shell
$ boot new template-name --out output-directory
```

Or use the -o shorthand

```shell
$ boot new template-name -o output-directory
```

### List all templates
To list all avaiable templates run
```shell
$ boot template --list
```

### Template spesific options
All template may have template spesific options. What these options are used for vary from template to template.
Maybe choose vcs, set the name of your project, or something else.

To list all avaiable options for a template run
```shell
$ boot template [template-name]
```

When passing options to a template, -- is used to seperate options to the *new* sub command and options for the template
```shell
$ boot new [options to the 'new' subcommand] -- [options to the spesified template]
# For example
$ boot new gem -o my-gem -- --name "My Gem" --description "Does gemmy things"
```


## Tips

### Aliasing
If you mostly create project of a spesific type, say, wordpress-plugins, you can use alias to make boot more 
practical

```shell
$ alias "wordpress-plugin"="boot new wordpress-plugin -o . --"
```

This aliases the boot command that creates the starting point of a WordPress plugin in the current directory
to the command `wordpress-plugin`

Now you can run

```shell
$ mkdir new-plugin
$ cd new-plugin
$ wordpress-plugin --name "My Plugin" --description "Does stuff"
```

## Writing custom templates walkthrough

You can write your own templates, and make use of them with boot.
To do this, you first need to create a directory were you templates are.
Lets create a boot-templates directory in out user directory

```shell
$ mkdir ~/boot-templates
```

Now, you need to setup a .boot dot file, to tell boot to look for templates in this directory.

```shell
$ touch ~/.boot
```

The .boot dot file uses json syntax, and you need to set the "templates_path" key to be an array
of template directories, or just a single string with one directory. I'm gonna use an array here.
Set the content of the new ~/.boot file to be

*~/.boot*
```json
{
  "templates_path" : ["~/boot-templates"]
}
```

### Writing the template

Now you're ready to write templates in the boot-templates path.
We'll use boot to create a starting point for out new boot-template

```shell
$ cd ~/boot-templates
$ boot new boot-template -o php -- --name PHP --description "Starting point for a PHP project"
```

Quick overview. All boot templates can have "static" and "option" files. Static files included no matter what
options passed to the templates are. "option" files are included based on the options passed.

Lets set up our static files first

Boot already created the static directory, so we'll just create an index.php in this dir.

```shell
$ cd ~/boot-templates/php
$ echo "<?php" > static/index.php
```

Now, whenever you run

```shell
$ boot new php -o some-dir
```

Boot will create `some-dir` and put the index.php file in there.

### Options

A little bit more advanced, is, optionally include a .gitignore file if the --vcs option passed to the
template is "git"

First, for the sake of structure, we'll create a 'vcs' directory,
and then put our .gitignore file in there

```shell
$ cd ~/boot-templates/php
$ mkdir vcs
$ touch vcs/.gitignore
```

And lests but "vendor/" in the gitignore

```shell
$ cd ~/boot-templates/php
$ echo "vendor/" > vcs.gitignore
```

Now we need to setup our template to accept the --vcs option.
open up the ~/boot-templates/php/template.json file.

After you edit it, it should look like this

*~/boot-templates/php/template.json*
```json
{
  "name" : "PHP",
  "description" : "Starting point for a PHP project",
  "static" : "static",

  "options" : {
    "--vcs" : {
      "description" : "Choose version controll system",
      "values" : {
        "git" : {"vcs/.gitignore":".gitignore"}
      }
    }
  }
}
```

The only thing we add is the "--vcs : [...]" part
The description key is the description of this option, and will
be displayed when the user runs `boot template php`.
The values are the different values this option may be, which point to the files
that should be included if the option is that value.
You'll notice that "git" point to an object. This is because, if you just write "vcs/.gitignore" as a string
boot will assume, that when a user creates a new project base on this template, it should create a vcs directory
and but the .gitignore in the there. The object tells boot to grap the file form the source(the key) and put
it in the dest(the value).

But what it we wan't the option to allow an inferior version contoll system, like svn.
Lets do that.
We'll just copy the .gitignore

```shell
$ cd ~/boot-templates
$ cp vcs/.gitignore vcs/.svnignore
```

Now lets edit the template.json file to accept svn


*~/boot-templates/php/template.json*
```json
{
  "name" : "PHP",
  "description" : "Starting point for a PHP project",
  "static" : "static",

  "options" : {
    "--vcs" : {
      "description" : "Choose version controll system",
      "values" : {
        "git" : {"vcs/.gitignore":".gitignore"},
        "svn" : {"vcs/.svnignore":".svnignore"}
      }
    }
  }
}
```

Right, so now you can run

```shell
$ boot new php -o some-project -- --vcs git
# or
$ boot new php -o some-project -- --vcs svn
```

### Flag options

Lets do a flag next. Flags in boot templates are argument that take no value, but when they are present
they include some files.
Lets setup a --autoloaded flag, which creates an autoload.php file in the root directory, and makes index.php
require this file.

First well create an autoload.php file in our template, lets put it in a misc directory

```shell
$ cd ~/boot-templates/php
$ mkdir misc
$ touch misc/autoload.php
```

Now, well also create an alternative index.php file, that will be included if the --audoloaded flag is present,
and will overwrite the one in out static folder.

```shell
$ cd ~/boot-templates/php
$ cp static/index.php misc/index-autoloaded.php
```

Now, lets edit that index-autoloaded.php file, so it contains the line to require the autoload.php

*~/boot-templates/misc/index-autoloaded.php*
```php
<?php
require_once __DIR__ . "/autoload.php"
```

Greate, lets setup the option in our template.json. The "syntax" for create flag are slightly different.
Lets edit our template.json file

*~/boot-templates/php/template.json*
```json
{
  "name" : "PHP",
  "description" : "Starting point for a PHP project",
  "static" : "static",

  "options" : {
    "--vcs" : {
      "description" : "Choose version controll system",
      "values" : {
        "git" : {"vcs/.gitignore":".gitignore"},
        "svn" : {"vcs/.svnignore":".svnignore"}
      }
    },
    "--autoloaded" : {
      "description" : "Add an autoload.php file, thats included in the index.php",
      "files" : [
        {"misc/autoload.php":"autoload.php"},
        {"misc/index-autoloaded.php":"index.php"}
      ]
    }
  }
}
```

Now you can run
```shell
$ boot new php -o some-project -- --autoloaded
```

And the index.php will contain the "require_once[...]" line, and the autoloaded.php file will be included

### Symbols

Symbols in boot, allows you to accept an option, and replace content in files or filenames based on the value
of the symbol

Lets set up one that will create a comment at the top of out index.php file containing the name of the project

Lets edit our template.json file to accept one

*~/boot-templates/php/template.json*
```json
{
  "name" : "PHP",
  "description" : "Starting point for a PHP project",
  "static" : "static",

  "options" : {
    "--vcs" : {
      "description" : "Choose version controll system",
      "values" : {
        "git" : {"vcs/.gitignore":".gitignore"},
        "svn" : {"vcs/.svnignore":".svnignore"}
      }
    },
    "--autoloaded" : {
      "description" : "Add an autoload.php file, thats included in the index.php",
      "files" : [
        {"misc/autoload.php":"autoload.php"},
        {"misc/index-autoloaded.php":"index.php"}
      ]
    },
    "--name" : {
      "description" : "Set the project name",
      "deafult" : "project-name",
      "symbol" : "project-name"
  }
}
```

*The deafult key is not required. But if its not present, then the user will be required to specify this option when
running boot with this template.*

Then we need to edit out static/index.php and misc/index-autoloaded.php to retrive the value of the symbol

*~/boot-templates/php/static/index.php*
```php
<?php
// THIS IS [[!project-name]]!
```

*~/boot-templates/php/misc/index-autoloaded.php*
```php
<?php
// THIS IS [[!project-name]]!
require_once __DIR__ . "/autoload.php"
```

[[!symbol]] is the syntax for retriving the value of a symbol

Now you could run
```shell
$ boot new PHP -o my-php-project -- --name SPARTA
```

Footnote:
I didn't find an easy way to include this info in the walkthough, so

**You can use [[!symbol]] in file names**
You can setup a static/[[!project-name]]/ dir forexample to allways create a directory with the name of the project

**Use [[!symbol]] in template.json**
When using {"file/src":"file/dest"} in the template.json file, you can use [[!symbol]] in the destination part
