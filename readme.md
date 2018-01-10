# SilverStripe vagrant image for Windows 10

## Getting started

```
# Setup
git clone https://github.com/tractorcow/silverstripe-vagrant-win.git ./myvagrant
cd myvagrant/Sites
composer create-project silverstripe/installer ./ss40test ^4 --prefer-source
cd ..

# Start vagrant
vagrant up
```

# Browsing your site

You can access your site at `http://127.0.0.1:9090/myvagrant/`

# RDP

Install https://itunes.apple.com/us/app/microsoft-remote-desktop-8-0/id715768417?mt=12

Then access with `vagrant rdp`

# Logging in

If you need to login the default user details are:

- User: vagrant
- Password: vagrant
