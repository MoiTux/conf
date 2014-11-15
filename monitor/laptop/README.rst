Laptop screen
=============

To auto (de)activate the laptop's screen when closing it

Find ACPI event:
----------------
to do that use `acpi_listen` command and close/open the laptop's screen:

.. code:: bash

          $ acpi_listen
          button/lid LID close
          button/lid LID open

Create a new ACPI event:
------------------------
Create a new file in `/etc/acpi/event/my_acpi_event`.
You need two things in that file:
* the `event` variable
* the `action` variable
The `event` is the first column in the return of `acpi_listen`.
The `action` is the script to be executed.

You can use `%e` in the end of the command you set in action to get the the
same information that `acpi_listen` returned (careful they will be parameter)

.. note::
systemd might be set to do something else when closing/opening the
lapotop's screen.
Open the file `/etc/systemd/logind.conf` and check for the variable
`HandleLidSwitch`, if it's commented or someting other than `ignore`
you'll need to changed it.
