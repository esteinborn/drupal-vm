# TODO: Single command to setup, download database, etc
# http://stackoverflow.com/questions/14124234/how-to-pass-parameter-on-vagrant-up-and-have-it-in-the-scope-of-chef-cookbook
# drush @YOUR-ALIAS.dev sql-dump --structure-tables-list="hist*,cache*,*cache,sessions" | drush @drupalvm.drupalvm.dev sql-cli

# When vtests/package.json exists, run npm install