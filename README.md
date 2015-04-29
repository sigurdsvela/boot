# boot
A command line tool for quickly creating starting points for projects based on different templates

Boot contains different templates to create different types of projects(see 'List all templates')

## Installation
Currenly, to install boot, you must clone the repository(make sure to clone *all submodules*)
and then run
```shell
$ rake gembuild geminstall
```

## Usage

### Create new project
To create a new project base on a template run
```shell
$ boot new -t template-name -o output-directory
```

### List all templates
To list all avaiable templates run
```shell
$ boot tempalte --list
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
$ boot new -t gem -o my-gem -- --name "My Gem" --description "Does gemmy things"
```


## Tips

### Aliasing
If you mostly create project of a spesific type, say, wordpress-plugins, you can use alias to make boot more 
practical

```shell
$ alias "wordpress-plugin"="boot new -t wordpress-plugin -o . --"
```

This aliases the boot command that creates the starting point of a WordPress plugin in the current directory
to the command `wordpress-plugin`

Now you can run

```shell
$ mkdir new-plugin
$ cd new-plugin
$ wordpress-plugin --name "My Plugin" --description "Does stuff"
```
