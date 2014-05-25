#!/bin/bash

function hashUserData {
	_sec_user=$( echo $1 | sha256sum | head -c 64 )
	_sec_pass=$( echo $2 | sha256sum | head -c 64 )
	echo "$_sec_user;$_sec_pass"
}

function notAuthorized {
	dialog 	--title 'Acesso negado'								\
			--infobox '\nUsuário e/ou senha incorretos'			\
			5 40
}

function login {
	_username=$( dialog                                         \
				--stdout										\
			   	--title 'Login'                          		\
			   	--inputbox 'Insira o nome do seu usuario:'   	\
			   	0 0 )

	_password=$( dialog                                         \
				--stdout										\
				--insecure										\
			   	--title 'Login'                          		\
			   	--passwordbox 'Insira a sua senha:'			   	\
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

function newUser {
	_username=$( dialog                                         \
				--stdout										\
			   	--title 'Login'                          		\
			   	--inputbox 'Insira o nome do seu usuario:'   	\
			   	0 0 )

	_password=$( dialog                                         \
				--stdout										\
				--insecure										\
			   	--title 'Login'                          		\
			   	--passwordbox 'Insira a sua senha:'			   	\
			   	0 0 )

	addUser $_username $_password
}

function addUser {
	echo "$( hashUserData $1 $2 )" >> data/users
}

function showMenu {
	_choice=$( dialog                                 				\
		--stdout								  					\
	   	--title 'Agenda'                          					\
	   	--menu 'Escolha a ação desejava:' 							\
	   	0 0 0                                     					\
	   	1  'Cadastrar Contato'           							\
	   	2  'Listar Contatos'               							\
	   	3  'Cadastrar Usuario'               						\
	   	4  'Sobre Agenda' )

	case $_choice in
		'1') echo "Cadastrar Tarefa";;
		'2') echo "Listar Tarefas";;
		'3') newUser ;;
		'4') echo "Sobre ContatosBASH";;
		*) echo $_choice;;
	esac
}

login