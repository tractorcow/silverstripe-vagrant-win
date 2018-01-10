# SilverStripe vagrant image for Windows Server 2016

## Getting started

```
# Setup
git clone https://github.com/tractorcow/silverstripe-vagrant-win.git ./myvagrant
cd myvagrant/Sites
composer create-project silverstripe/installer ./ss40test ^4 --prefer-source
cd ..

# Start vagrant
vagrant up
vagrant rdp
```

# Browsing your site

You can access your site at `http://127.0.0.1:9090/Sites/ss40test/`

# Database

No MySQL is configured for this image; We suggest that you use sqlite3 instead (or set this up yourself)

# RDP

Install https://itunes.apple.com/us/app/microsoft-remote-desktop-8-0/id715768417?mt=12

Then access with `vagrant rdp`

User credentials are:

 - User: vagrant
 - Password: vagrant

# todo

 - chocolately doesn't actually work for some reason, thus urlrewrite step fails. You will
   need to install and configure this manually.
 - If you don't configure urlrewrite, then index.php / install.php will work but no other urls
 - The symlinked `Sites` folder actually isn't writable by IIS, which breaks installer as well
   as `assets` dir. You should probably install your project fresh in an adjacent subdirectory
   instead of the symlinked one.
 - We probably should setup mysql, maybe once we get chocolately working properly. Just use
   sqlite for now.
