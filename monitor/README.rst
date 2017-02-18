=========================
Auto-setup / Clone screen
=========================

Auto-setup
==========
The script `monitor.sh` can be used to automatically setup and configure
a new plugin screen, it can also be used to deactivate an unplugged screen.

New screen is always added to the right of the previous screen.

.. note::

         The laptop's screen (eDP-1) is always force has the first screen in the line

UDEV event
----------
By using the udev event the script will be automatically called when plug-in
or unplug-in a screen.

.. note::

         The laptop's screen doesn't send udev event when open/close  
         see `laptop/README.rst`

To find the needed information to create the udev rule use the command
`udevadm monitor -kp`, then plug,unplug a screen

.. code:: bash

          $ udevadm monitor -kp
          monitor will print the received events for:
          KERNEL - the kernel uevent

          KERNEL[17746.317617] change   /devices/pci0000:00/0000:00:02.0/drm/card0 (drm)
          ACTION=change
          DEVNAME=/dev/dri/card0
          DEVPATH=/devices/pci0000:00/0000:00:02.0/drm/card0
          DEVTYPE=drm_minor
          HOTPLUG=1
          MAJOR=226
          MINOR=0
          SEQNUM=2200
          SUBSYSTEM=drm

UDEV rule
---------
Create a file in `/etc/udev/rules.d/` the filename must end with `.rules`.
Using the result of the previous command add a line like this one and save it:

.. code::

          ACTION=="change", KERNEL=="card0", SUBSYSTEM=="drm", DEVPATH=="/devices/pci0000:00/0000:00:02.0/drm/card0", RUN+="/usr/local/bin/monitor"

That's all from now each time a screen will be plug/unplug the script will be
called and the right modification to correctly set the screen will be done.

Clone
=====

Cloning a screen is something useful when doing a presentation, you can have
a screen in front of you and one in the back for the audience.

The `clone.sh` script will do that, both screen will have there preferred
resolution used, but a transformation will be added to the cloned screen if
both screen have different resolution so the image will correctly fit in both
screen.
