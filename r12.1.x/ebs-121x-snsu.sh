#!/bin/bash
#-----------------------------------------------------------------------------------------------------------#
# Startup/Shutdown Utility Script for Oracle E-Business Suite 12.1.x                                        #
# This script is licenced under GPLv2 ; you can get your copy from http://www.gnu.org/licenses/gpl-2.0.html #
# (C) Omkar Dhekne ; ogdhekne@yahoo.in                                                                      #
# This script requires 'dialog' package installed in system. To check # rpm -qa  | grep dialog              #
# * IMPORTANT: Set BASE, SID, HOST  before running script.                                                  #
#-----------------------------------------------------------------------------------------------------------#

# -- ENV:
	export BASE=""
	export SID=""
	export HOST="`hostname -a`"

# -- COLORS:
	export RESET="\e[0m"
	export GRAY="\e[100m"

# -- PROCESSES:
    export LISTN="$(ps -ef |  grep tns | grep 11.2.0 | wc -l)"
    export DB="$(ps -ef | grep ora_ | grep $SID | wc -l)"
    export APP="$(ps -ef | grep FND | wc -l)"

# -- FUNC:
	start()
	{

	# -- START DB:
		source $BASE/db/tech_st/11.1.0/$SID\_$HOST.env

		$BASE/db/tech_st/11.1.0/appsutil/scripts/$SID\_$HOST/addlnctl.sh start $SID
		$BASE/db/tech_st/11.1.0/appsutil/scripts/$SID\_$HOST/addbctl.sh start

	# -- START APPS:
		source $BASE/apps/apps_st/appl/APPS$SID\_$HOST.env

		$BASE/inst/apps/$SID\_$HOST/admin/scripts/adstrtal.sh apps/apps

	# -- PRINT MESSAGE:
		echo "                                           "
		echo -e "Press ${GRAY:-} [Enter] ${RESET:-} to exit."
		read enter
	}

	stop()
	{

	# -- STOP APPS:
		source $BASE/apps/apps_st/appl/APPS$SID\_$HOST.env

		$BASE/inst/apps/$SID\_$HOST/admin/scripts/adstpall.sh apps/apps

	# -- STOP DB:
		source $BASE/db/tech_st/11.1.0/$SID\_$HOST.env

		$BASE/db/tech_st/11.1.0/appsutil/scripts/$SID\_$HOST/addlnctl.sh stop $SID
		$BASE/db/tech_st/11.1.0/appsutil/scripts/$SID\_$HOST/addbctl.sh stop immediate

	# -- PRINT MESSAGE:
		echo "                                           "
		echo -e "Press ${GRAY:-} [Enter] ${RESET:-} to exit."
		read enter

	}

	status()
	{
		echo "                                           "
		# -- PRINT STATUS OF DB, APPS & LISNTENER
			cat <<EOF
			Processes:
			DB: $DB   APPS: $APP  LISTENER: $LISTN
EOF


		# -- PRINT MESSAGE:
			echo "                                           "
			echo -e "Press ${GRAY:-} [Enter] ${RESET:-} to return main-menu."
			read enter

	}


# -- MAIN MENU:
	menu=(dialog --clear --backtitle "STARTUP/SHUTDOWN UTILITY FOR EBS 12.1.x " --title "[ M A I N - M E N U ]" \
		--menu "               NOTE: USE ARROW KEYS TO NAVIGATE" 15 68 4)

	options=(Startup	"Start DB & APPS Services."
			Shutdown	"Stop APPS & DB Services."
			Status		"Status of DB, APPS & LISTENER."
			Exit		"Exit to the shell")


	choices=$("${menu[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
		case $choice in
			Startup) clear && start ;;
			Shutdown) clear && stop ;;
			Status) clear && status ;;
			Exit) clear && echo "Bye"; break;;
		esac
	done