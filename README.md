
## project initialize
> mkdir flipr
> cd flipr
> git init .
Initialized empty Git repository in /flipr/.git/
> touch README.md
> git add .
> git commit -am 'Initialize project, add README.'


### Sqitch initialization
> sqitch init flipr --uri https://github.com/sqitchers/sqitch-intro/ --engine pg
Created sqitch.conf
Created sqitch.plan
Created deploy/
Created revert/
Created verify/

### sqitch.conf
> cat sqitch.conf
[core]
        engine = pg
        # plan_file = sqitch.plan
        # top_dir = .
# [engine "pg"]
        # target = db:pg:
        # registry = sqitch
        # client = psql


        

<p>By default, Sqitch will read sqitch.conf in the current directory for settings. But it will also read ~/.sqitch/sqitch.conf for user-specific settings. Since PostgreSQL’s psql client is not in the path on my system, let’s go ahead and tell it where to find the client on our computer (don’t bother if you’re using the Docker image because it uses the client inside the container, not on your host machine):   <p>

> sqitch config --user engine.pg.client /opt/local/pgsql/bin/psql

> sqitch config --user engine.pg.client /opt/local/pgsql/bin/psql


And let’s also tell it who we are, since this data will be used in all of our projects:

> sqitch config --user user.name 'Marge N. O’Vera'
> sqitch config --user user.email 'marge@example.com'

Have a look at ~/.sqitch/sqitch.conf and you’ll see this:

> cat ~/.sqitch/sqitch.conf

Have a look at the plan file, sqitch.plan:
> cat sqitch.plan

Let’s commit these changes and start creating the database changes.
> git add .
> git commit -am 'Initialize Sqitch configuration.'

First, our project will need a schema. 
> sqitch add appschema -n 'Add schema for all flipr objects.'


Now we can try deploying this change. First, we need to create a database to deploy to:

> createdb flipr_test

> sudo createdb -h localhost -U postgres flipr_test             //right one

> sudo sqitch deploy db:pg://postgres:postgres@localhost/flipr_test 

First Sqitch created registry tables used to track database changes.

> sudo psql -h localhost -U postgres -d flipr_test -c '\dn flipr'

> sudo sqitch verify db:pg://postgres:postgres@localhost/flipr_test


#### Status, Revert, Log, Repeat
> sudo sqitch status db:pg://postgres:postgres@localhost/flipr_test

> sudo sqitch revert db:pg://postgres:postgres@localhost/flipr_test  //You can pass the -y option to disable the prompt. 

> sudo psql -h localhost -U postgres -d flipr_test -c '\dn flipr'

> sudo sqitch log db:pg://postgres:postgres@localhost/flipr_test


### Deploy with --verify
> sudo sqitch deploy --verify db:pg://postgres:postgres@localhost/flipr_test


### On Target
but we don’t have to keep using the URI. We can name the target:

> sqitch target add flipr_test db:pg://postgres:postgres@localhost/flipr_test
But since we’re doing so much testing, we can also use the engine command to tell Sqitch to deploy to the flipr_test target by default:

> sqitch engine add pg flipr_test

Yay, that allows things to be a little more concise. Let’s also make sure that changes are verified after deploying them:

> sqitch config --bool deploy.verify true
> sqitch config --bool rebase.verify true

> git commit -am 'Set default deployment target and always verify.'

### Deploy with Dependency

> sudo sqitch add users --requires appschema -n 'Creates table to track our users.'

> sudo sqitch deploy

purposes of visibility, let’s have a quick look:

> sudo psql -h localhost -U postgres -d flipr_test -c '\d flipr.users'

We can also verify all currently deployed changes with the verify command:

> sqitch verify

> sqitch verify

> sudo sqitch status

Success! Let’s make sure we can revert the change, as well:

> sudo sqitch revert --to @HEAD^ -y

> psql psql -h localhost -U postgres -d flipr_test -c '\d flipr.users'

> sudo sqitch status

> sudo sqitch verify

> git add .

> git commit -am 'Add users table.'

### Add Two at Once

> sqitch add insert_user --requires users --requires appschema \
  -n 'Creates a function to insert a user.'

> sqitch add change_pass --requires users --requires appschema \
  -n 'Creates a function to change a user password.'

> cat sqitch.plan


> sudo sqitch deploy

> sudo psql -h localhost -U postgres -d flipr_test -c '\df flipr.*'

> sudo sqitch status

> sudo sqitch revert -y --to @HEAD^^


**Note** the use of @HEAD^^ to specify that the revert be to two changes prior the last deployed change. Looks good. Let’s do the commit and re-deploy dance:

> git add .
> git commit -m 'Add `insert_user()` and `change_pass()`.'

> sudo sqitch deploy

> sudo sqitch status

> sudo sqitch verify

### Ship It!
Let’s do a first release of our app. Let’s call it 1.0.0-dev1 Since we want to have it go out with deployments tied to the release, let’s tag it:

> sudo sqitch tag v1.0.0-dev1 -n 'Tag v1.0.0-dev1.'

Tagged "change_pass" with @v1.0.0-dev1

> sudo git commit -am 'Tag the database with v1.0.0-dev1.'

[main 0acef3e] Tag the database with v1.0.0-dev1.
 1 file changed, 1 insertion(+)

> sudo git tag v1.0.0-dev1 -am 'Tag v1.0.0-dev1'

We can try deploying to make sure the tag gets picked up like so:

> sudo createdb -h localhost -U postgres flipr_dev

> sudo sqitch deploy db:pg://postgres:postgres@localhost/flipr_dev

> sudo sqitch status db:pg://postgres:postgres@localhost/flipr_dev



**Note** the listing of the tag as part of the status message. Now let’s bundle everything up for release:

> sudo sqitch bundle

- Now we can package the bundle directory and distribute it. When it gets installed somewhere, users can use Sqitch to deploy to the database. Let’s try deploying it:

    
      > cd bundle

      > sudo createdb  -h localhost -U postgres flipr_prod

      > sudo sqitch deploy db:pg://postgres:postgres@localhost/flipr_prod
    
      Adding registry tables to db:pg:flipr_prod

      Deploying changes to db:pg:flipr_prod
    
      + appschema ................. ok
    
      + users ..................... ok
    
      + insert_user ............... ok
    
      + change_pass @v1.0.0-dev1 .. ok

  Looks much the same as before, eh? Package it up and ship it!

    
    > cd ..
    
    > mv bundle flipr-v1.0.0-dev1
    
    > tar -czf flipr-v1.0.0-dev1.tgz flipr-v1.0.0-dev1

### Flip Out
  > git checkout -b flips 
  
  Switched to a new branch 'flips' 
  Now we can add a new change to create a table for our flips.
  
  > sudo sqitch add flips -r appschema -r users -n 'Adds table for storing flips.'

  > sudo sqitch deploy

  > sudo sqitch status --show-tags**

**Note** the use of --show-tags to show all the deployed tags. Now make it so:

  > git add .
  
[flips e8f4655] Add flips table.

  > git commit -am 'Add flips table.'


  ### Wash, Rinse, Repeat


add insert_flip and delete_flip changes and commit them.

  > sudo sqitch add insert_flip  --requires users --requires appschema  -n 'Creates a function to insert a flip.'

  > sudo sqitch add delete_flip  --requires users --requires appschema  -n 'Creates a function to delete a flip.'

  > sudo sqitch revert -y --to @HEAD^^

  > sudo sqitch status --show-tags

  > git add .
  
  [flips e8f4655] Add flips table.

  > git commit -am 'Add flips table.'

  Good, we’ve finished this feature. Time to merge back into main.
  
### Emergency

  > git checkout main
  
  > git pull