#!/bin/bash

#################### GLOBAL ####################
PATTERN_EMAIL="^[a-Z|0-9]+@[a-Z0-9]+\.[a-z]"
PATTERN_PHONE="^[0-9]+$"
#################### GLOBAL ####################



#################### UTIL FUNCTIONS ####################
function hashUserData {
	_sec_user=$( echo $1 | sha256sum | head -c 64 )
	_sec_pass=$( echo $2 | sha256sum | head -c 64 )
	echo "$_sec_user;$_sec_pass"
}
#################### UTIL FUNCTIONS ####################








#################### LOGIN FUNCTIONS ####################
function notAuthorized {
	dialog 	--title "Access denied" --msgbox "\nInvalid user and/or password" 0 0
}

function login {
	_username=$( dialog                                         \
				--stdout										\
			   	--title "Logon"                          		\
			   	--inputbox "Username:" 						  	\
			   	0 0 )

	_password=$( dialog                                         \
				--stdout										\
				--insecure										\
			   	--title "Logon"                          		\
			   	--passwordbox "Password:"					   	\
			   	0 0 )

	_auth_data=$( hashUserData $_username $_password )

	if grep -q $_auth_data data/users; then
		showMenu

	else
		notAuthorized

	fi
}

function validateAccess {
	_users=$( cat data/users )
}
#################### LOGIN FUNCTIONS ####################






#################### USER FUNCTIONS ####################
function newUser {
	_username=$( dialog                                         \
				--stdout										\
			   	--title "New user"                          	\
			   	--inputbox "Type the username:" 				\
			   	0 0 )

	_password=$( dialog                                         \
				--stdout										\
				--insecure										\
			   	--title "New user"                         		\
			   	--passwordbox "Type the password:"			   	\
			   	0 0 )

	addUser $_username $_password
}

function addUser {
	echo "$( hashUserData $1 $2 )" >> data/users
	showMenu
}
#################### USER FUNCTIONS ####################




#################### CONTACT FUNCTIONS ####################
function newContact {
	_name=$( dialog   		                                    \
				--stdout										\
			   	--title "New contact"                 	     	\
			   	--inputbox "Type the contact's name:" 		  	\
			   	0 0 )

	_phone=$( dialog   		                                    \
				--stdout										\
			   	--title "New contact"                      		\
			   	--inputbox "Type the contact's phone:" 			\
			   	0 0 )

	_email=$( dialog   		                                    \
				--stdout										\
			   	--title "New contact"  	                    	\
			   	--inputbox "Type the contact's e-mail:" 		\
			   	0 0 )
	

	validate $_phone $PATTERN_PHONE "Invalid phone format"
	validate $_email $PATTERN_EMAIL "Invalid email format"

	addContact $_name $_phone $_email
}

function validate {
	_var=$1
	_pattern=$2
	_message=$3

	if echo $_var | egrep $_pattern; then
		echo "VALID"

	else
		dialog 	--title "Error" --msgbox "\n$_message" 0 0 
		newContact

	fi
}

function addContact {
	if grep -q "^$1" data/contacts; then
		dialog 	--title "Warning" --msgbox "\nThere is alreay a contact using this name" 0 0
		showMenu

	else
		_lastId=$( tail -2 data/contacts | head -1 | awk -F\; '{print $1}')
		_newId=$( expr $_lastId + 1 )
		echo "$_newId;$1;$2;$3" >> data/contacts
		showMenu

	fi
}

function showContacts {
	_dialogContacts="dialog --stdout --title 'Agenda' --menu 'All registered contacts:' 0 60 0 "
	
	for _contact in $( cat data/contacts ); do
		_id=$( echo $_contact | awk -F\; '{print $1}' )
		_contact=$( echo $_contact | awk -F\; '{print $2}' )
		_dialogContacts="$_dialogContacts $_id '$_contact'" 
	done

	eval $_dialogContacts
	showMenu
}
#################### CONTACT FUNCTIONS ####################






#################### ABOUT FUNCTIONS ####################
function aboutContactsManager {
	dialog 	--title "About ContactsManager" \
			--msgbox "\nStarted by Leonardo Silva (leosilvadev@gmail.com). \n\nOpened in:\nhttps://github.com/leosilvadev/ContactsManager-BASH\n" 0 0
	showMenu
}
#################### ABOUT FUNCTIONS ####################




#################### MAIN MENU ####################
function showMenu {
	_choice=$( dialog                                 				\
		--stdout								  					\
	   	--title 'Options'                          					\
	   	--menu 'Choose an action:' 									\
	   	0 0 0                                     					\
	   	1  'Add new contact'           								\
	   	2  'List contacts' 	              							\
	   	3  'Edit contact' 	              							\
	   	4  'Delete contact' 	              						\
	   	5  'Add new user'               							\
	   	6  'About' )

	case $_choice in
		'1') newContact ;;
		'2') showContacts ;;
		'3') echo "Edit contact" ;;
		'4') echo "Delete contact" ;;
		'5') newUser ;;
		'6') aboutContactsManager ;;
		*) echo $_choice;;
	esac
}
#################### MAIN MENU ####################

login