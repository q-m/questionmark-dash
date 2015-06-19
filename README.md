Questionmark Dashboard, based on [Dashing](http://shopify.github.io/dashing).

## Install

`bundle install`

## Run

`dashing start`

## Configure
The mixpanel widget uses an API key and secret. Obtain the key / secret from the Mixpanel admin within Questionmark and add it to your `.bash_profile` or `/etc/init.d/dashing` (see below). Google Analytics needs a PKCS#12 file and service account email address for authentication, as well as profile ids.

```
export MIXPANEL_API_KEY=XXX
export MIXPANEL_API_SECRET=XXX
export QM_BARCODES_URL=XXX
export GA_KEY_FILE=~/.google-analytics.p12
export GA_ACCOUNT_EMAIL=xxx@developer.gserviceaccount.com
export GA_PROFILE_ID_WEB=xxx
export GA_PROFILE_ID_APP=xxx
export MAILCHIMP_API_KEY=xxx
```

## Restart dashboard after code change
First do `git pull` on the repository, then restart Dashing and Lightdm (the desktop manager):

```sh
sudo /etc/init.d/dashing stop && sudo /etc/init.d/dashing start && sudo /etc/init.d/lightdm restart
```

## Run on a Raspberry Pi
Some hints to get this running on a [Raspberry Pi](http://raspberrypi.org/):

1. [Install Raspbian](https://raspberrypi.org/downloads/), configure, set password, etc.
2. `apt-get install bundler`
3. [Install node.js](https://github.com/nathanjohnson320/node_arm)
4. `git clone https://github.com/q-m/questionmark-dash`
5. `cd questionmark-dash && bundle install`
6. `sudo cp initscript /etc/init.d/dashing && update-rc.d dashing defaults`
7. Edit `/etc/init.d/dashing` and edit the configuration variables on top.
8. `sudo apt-get install chromium-browser unclutter x11-xserver-utils`
9. `ln -s xsession ~/.xsession`
10. `cat screen.cron | sudo tee /etc/crontab`
11. Run `sudo raspi-config` and choose _Enable boot to desktop_ &gt; _Desktop Log in as user 'pi' ..._.
12. Reboot.

Remember to have some patience, as the Raspberry Pi is not _that_ fast. After the desktop appears,
it may take quite a while for Dashing to be fully up (at which point the browser appears as a white window)
and be shown (it can take more than a minute for nodejs to compile the assets at first visit).

See also
* [Setting up a Raspberry Pi as a dashboard server with Dashing](https://gist.github.com/stonehippo/5896381)
* [DIY Info-screen using a Raspberry Pi and Dashing](http://www.fusonic.net/en/blog/2013/07/31/diy-info-screen-using-raspberry-pi-dashing/)
* [Running Shopify’s Dashing on a Raspberry Pi](http://toxaq.com/index.php/2012/12/running-shopifys-dashing-on-a-raspberry-pi/)

## License

Distributed under the terms of the [MIT license](LICENSE.md).
