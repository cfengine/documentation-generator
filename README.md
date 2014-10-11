Jekyll config for CFEngine documentation
===========


1. Installation
-

See the `Dockerfile` in `_setup` for how to provision an
installation of jekyll that can build the documentation.

If pandoc is used, you need in addition

+ pandoc-ruby
+ rdiscount

2. Run
-

Build the image from `_setup/Dockerfile`, then run it:

    $ docker build -t my/cfengine-doc _setup
    $ docker run -P my/cfengine-doc [<branch>|master] [--remote|r <remote>] [--no-jekyll|--no-server]

3. Config
-

To configure jekyll open _config.yml. All options described at https://github.com/mojombo/jekyll/wiki/Configuration

