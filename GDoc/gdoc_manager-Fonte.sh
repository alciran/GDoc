#!/bin/bash
#script para criar um novo projeto e novo package no padrão GDoc
#Autor: Alciran Franco
#alciranfranco@gmail.com

##### VARIAVEIS GLOBAIS #####
file_log=""
date=`date +"%d-%m-%Y_%H-%M-%S"`

##### FIM VARIAVEIS GLOBAIS #####

function checkLanguage(){
  pathLang="languages/$LANGUAGE.lang"
  if [ -e $pathLang ] ; then
	  . $pathLang
  else
	  if [ -e languages/en_US.lang ] ; then
		  . ./languages/en_US.lang
	  else
		  echo -e "[GDoc]: [\033[00;31mErro\033[00m] Arquivo padrão de linguagem removido ou inexistente."
		  exit 0;
	  fi
  fi
}

function print_message(){
  type=$1
  message=$2
  if [ -z "$3" ] ; then
    log=0
  else
    log=$3
  fi
  echo -e "$header $type $message"
  if [ $log -eq 1 ] ; then
    echo "[$(date +"%d-%m-%Y %T")] $header $message" >> "$file_log"
  fi
}

function exit_with_error(){
  print_message $error "$close_with_error"
  exit -1
}

function exit_with_success(){
  package_name=$1
  print_message $ok "$close_with_success"
  exit 0
}

function createProject(){ 
  read -p "$get_name_project " project_name
  read -p "$get_ower_project " project_owner
  if [ -z "$project_name" ] ; then
    project_name="Project_$date"
  fi

  #Cria arquivo de log para novo projeto
  file_log="logs/Project_$project_name.log"
  touch "$file_log"
  print_message "$ok" "$creating_new_project $project_name" 1

  #Criar os diretórios necessários
  if [ -d "projects/$project_name" ] ; then 
    print_message $warning "$already_exist_dir $project_name" 1
    date=`date +"%d-%m-%Y_%H-%M-%S"`
    date="_$date"
    project_dir="$project_name$date"
    print_message "" "$creating_new_directory $project_dir"
  else
    project_dir="$project_name"
  fi

  #Criando diretorios necessarios
  mkdir -pv projects/"$project_dir"/{packages,public_gdocs} | tee -a "$file_log"

  if [ $(echo $?) -ne 0 ] ; then
    print_message $error "$error_create_root_dir"
    exit_with_error
  fi

  #Criar o arquivo .conf do projeto
  touch projects/"$project_dir"/project.conf
  if [ $(echo $?) -ne 0 ] ; then
    print_message $error "$error_create_project_conf_file"
    exit_with_error
  fi
  date=`date +"%d/%m/%Y %H:%M:%S"`
  echo -e "#Project Config\nname=$project_name\nowner=$project_owner\ncreateDate=$date\nnum_columns_cards=2\ngenerate_links_page=false" > projects/"$project_dir"/project.conf
  cp "components/package/footer.gdoc" "projects/$project_name/public_gdocs/"
}

function createPackage(){
  root_path="$1"
  #Checagem project.conf
  if [ -e "$root_path"/project.conf ] ; then
    project_name="`cat "$root_path"/project.conf | grep name= | cut -d= -f2`"
  else
    print_message $error "$error_missing_file_project_config"
    exit_with_error
  fi

  file_log="logs/Project_$project_name.log"

  if [ ! -e "$file_log" ] ; then
    touch $file_log
  fi

  if [ ! -d "$root_path"/packages ] ; then
    mkdir "$root_path"/packages
  fi

  #Criar package
  read -p "$get_name_package" package_name
  read -p "$get_author_package" package_author
  date=`date +"%d-%m-%Y_%H-%M-%S"`
  if [ -z "$package_name" ] ; then
    package_name="Package_$date"
  fi

  print_message "" "$creating_new_package '$package_name'" 1

  if [ -d "$root_path"/packages/"$package_name" ] ; then 
    print_message $warning "$already_exist_dir '$package_name'" 1
    #criar novo diretorio, nunca sobrescrever
    date=`date +"%d-%m-%Y_%H-%M-%S"`
    date="_$date"
    package_dir="$package_name$date"
    print_message "" "$creating_new_directory $package_dir" 1
  else
    package_dir="$package_name"
  fi

  mkdir -vp "$root_path"/packages/"$package_name"/gdocs | tee -a "$file_log"
  touch "$root_path"/packages/"$package_name"/package.conf
  print_message "$ok" "$create_config_file_package $created_success" 1

  #criando arquivo de configuracao
  echo -e "config{\npackage_name=$package_name\ncolorTheme=purple\nauthor=$package_author\noccupation=\nemail=\ndocVersion=1.0.0\nlastUpdate=$(date +"%d/%m/%Y %H:%M")\ngenerate_log=false\ncard_icon=fas fa-laptop-code\ndescription=\n}config" > "$root_path"/packages/"$package_name"/package.conf
  
  cat components/package/package_conf_default  >> "$root_path"/packages/"$package_name"/package.conf

  print_message "$ok" "Package '$package_name' $created_success" 1
}

function removeProject(){
  project_name="$1"
  if [ -n "$project_name" ] ; then
    if [ -d "projects/$project_name" ] ; then
      tar -czf "logs/backups/$project_name-$date.tar.gz" "projects/$project_name/"
      if [ $? -eq 0 ] ; then        
        rm -rf "projects/$project_name"
        if [ -d "../public/help/$project_name" ] ; then
          rm -rf "../public/help/$project_name"
        fi
        print_message $ok "'$project_name' => $project_removed_succesfully"
        exit 0
      else
        print_message $error "$project_backup_not_save $project_name"
      fi      
    else
      print_message $error "$project_not_found $project_name"
      exit_with_error
    fi
  else
    print_message $error "$argument_project_name_empty"
    exit_with_error
  fi
}

function removePackage(){
  package_dir_name="$2"
  if [ -z "$package_dir_name" ] ; then
    print_message $error "$argument_project_package_empty"
  elif [ -d "$package_dir_name" ] ; then
    package_name=$(echo "$package_dir_name" | cut -d/ -f 4 )
    project_name=$(echo "$package_dir_name" | cut -d/ -f 2 )
    package_name_no_space=$(echo "$package_name" | sed 's/ /_/g')
    tar -czf "logs/backups/$package_name-$date.tar.gz" "$package_dir_name"
    if [ $? -eq 0 ] ; then    
      rm -rf "$package_dir_name"    
      if [ -e "../public/help/$project_name/packages/$package_name_no_space.html" ] ; then
        rm -f "../public/help/$project_name/packages/$package_name_no_space.html"
      fi
      print_message $ok "'$package_name' => $package_removed_succesfully"
      read -p "$recompile_project" recompile
      if [ "$recompile" == "y" ] || [ "$recompile" == "yes" ] || [ "$recompile" == "Y" ] || [ "$recompile" == "YES" ] ; then
        cd "projects/$project_name"
        echo ""
        ../../gdoc_compiler.sh --compile-project
      else
        print_message "" "compiler: $please_reconpile_project"
      fi      
    else
      print_message $error "$package_backup_not_save $project_name"
    fi
  else
    print_message $error "$package_found '$package_dir_name'"
  fi
}

#Script
checkLanguage
case $1 in
--create-projet|-cpr)  
  createProject
;;
--create-package|-cpk)
  createPackage "$2"
;;
--remove-project|-rpr)
  removeProject "$2"
;;
--remove-package|-rpk)
  removePackage "$1" "$2"
;;
--help|-h)
echo "Ajuda ainda sera criada..."
;;
*)
print_message $error "$valid_arguments_for_script"
;;
esac