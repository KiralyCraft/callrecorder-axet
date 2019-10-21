##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "     Axet's Call Recorder      "
  ui_print " Magisk wrapper by KiralyCraft "
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() 
{
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  if [ "$BOOTMODE" = true ] ; then
	
	if [ "$API" -ge 19 ] ; then
		# ui_print "- Removing com.github.axet.callrecorder if it exists"
		
		ui_print "- Extracting privapp-permissions-axetcallrecorder.xml into /system/etc/permissions"
		unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
		
		ui_print "- Extracting APK from module zip"
		unzip -oj "$ZIPFILE" 'common/callrecorder1.7.6.apk' -d $MODPATH >&2
		ui_print "- Installing APK"
		
		pm install -g $MODPATH/callrecorder1.7.6.apk
		
		ui_print "- Checking installation success"
		
		installationResult=`pm list packages com.github.axet.callrecorder | grep -c com.github.axet.callrecorder`

		if [ $installationResult = 1 ] ; then
			
			ui_print "- Fetching installation folder directory"
			codePath=`dumpsys package com.github.axet.callrecorder | grep codePath | sed 's/codePath=//g' | tr -d " "`
			if [ ! -z $codePath ] ; then
				
				ui_print "- Checking if directory exists"
				if [ -d $codePath ] ; then
					
					destFolder="$MODPATH/system/priv-app/com.github.axet.callrecorder"
					ui_print "- Creating destination folder: $destFolder"
					mkdir -p $destFolder
					ui_print "- Copying installation files to destination from: $codePath"
					cp -R "$codePath/." "$destFolder"
					ui_print "- Uninstalling normal version of the APK"
					
					pm uninstall com.github.axet.callrecorder
					ui_print "- Removing temp APK"
					
					rm -f "$MODPATH/callrecorder1.7.6.apk"
					
					ui_print "- All done, please reboot!"
				else
					ui_print "! Directory location does not exist on disk: $codePath"
				fi
			else
				ui_print "! Could not fetch installation directory."
			fi
		else
			ui_print "! Installation of the APK failed."
		fi
	else
		ui_print "- This module only works for API >= 19 (KitKat)"
	fi
	
  else
	
	ui_print "- This module must be installed through Magisk Manager."
	
  fi
  
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code
